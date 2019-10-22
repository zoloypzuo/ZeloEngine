-- 应用转向力
--
-- 总结一下这个算法（可以认为是算法了）
-- 首先，必须意识到这是自己实现物理模拟计算
-- 一开始先前件检查，避免计算
-- 其实很简单，就是把力应用到agent上
-- 这个力的模调整为参数，最大力
-- 然后加到速度上
-- 然而我们只需要速度的方向，它代表agent的方向
function AgentUtilities_ApplyPhysicsSteeringForce(
        agent,
        steeringForce,
        deltaTimeInSeconds)
    --{{{尝试检查和避免计算
    -- 忽略很弱的力
    -- Ignore very weak steering forces.
    if (Vector.LengthSquared(steeringForce) < 0.1) then
        return ;
    end

    -- 0质量的agent不可移动
    -- Agents with 0 mass are immovable.
    if (agent:GetMass() <= 0) then
        return ;
    end
    --}}}
    -- y方向力设为0
    -- Zero out any steering in the y direction
    steeringForce.y = 0;

    -- 最大化转向力，先单位化得到方向，再乘以一个参数最大化
    -- Maximize the steering force, essentially forces the agent to max acceleration.
    steeringForce = Vector.Normalize(steeringForce) * agent:GetMaxForce();


    -- 应用该力
    -- Apply force to the physics representation.
    agent:ApplyForce(steeringForce);

    -- 得到加速度
    -- Newtons(kg*m/s^2) divided by mass(kg) results in acceleration(m/s^2).
    local acceleration = steeringForce / agent:GetMass();

    -- Velocity is measured in meters per second(m/s).
    local currentVelocity = agent:GetVelocity();

    -- 得到新速度
    -- Acceleration(m/s^2) multiplied by seconds results in velocity(m/s).
    local newVelocity = currentVelocity + (acceleration * deltaTimeInSeconds);

    -- y分量设为0
    -- Zero out any pitch changes to keep the Agent upright.
    -- NOTE: This implies that agents can immediately turn in any direction.
    newVelocity.y = 0;

    -- 设置agent的方向
    -- Point the agent in the direction of movement.
    agent:SetForward(newVelocity);
end

-- 第二个版本
-- 暂时没有空看区别，先跳过
function AgentUtilities_ApplySteeringForce2(
        agent, steeringForce, accelerationAccumulator, deltaTimeInSeconds)

    -- Ignore very weak steering forces.
    if (Vector.LengthSquared(steeringForce) < 0.1) then
        return ;
    end

    -- Agents with 0 mass are immovable.
    if (agent:GetMass() <= 0) then
        return ;
    end

    -- Zero out any steering changes in the y axis.
    steeringForce.y = 0;

    -- Maximize the steering force, essentially forces the agent to max
    -- acceleration.
    steeringForce = Vector.Normalize(steeringForce) * agent:GetMaxForce();

    -- Newtons(kg*m/s^2) divided by mass(kg) results in acceleration(m/s^2).
    local acceleration = steeringForce / agent:GetMass();

    -- Interpolate to the new acceleration to dampen jitter in velocity and
    -- forward direction.
    acceleration = accelerationAccumulator +
            (acceleration - accelerationAccumulator) * 0.4;

    -- Reassign the new acceleration back to the accumulator.
    accelerationAccumulator.x = acceleration.x;
    accelerationAccumulator.y = acceleration.y;
    accelerationAccumulator.z = acceleration.z;

    -- Calculate the new velocity in (m/s)
    local velocity = agent:GetVelocity() + (acceleration * deltaTimeInSeconds);

    -- Assign the velocity directly, and orient toward the movement.
    agent:SetVelocity(velocity);

    -- Prevent trying to set the forward to a Zero vector.
    if (Vector.LengthSquared(velocity) > 0.1) then
        velocity.y = 0;

        -- Interpolate to the new forward direction to dampen jitter.
        local forward = agent:GetForward();
        forward = forward + (Vector.Normalize(velocity) - forward) * 0.2;
        agent:SetForward(forward);
    end
end

-- 钳制水平速度
function AgentUtilities_ClampHorizontalSpeed(agent)
    local velocity = agent:GetVelocity();
    -- Store downward velocity to apply after clamping.
    local downwardVelocity = velocity.y;

    -- Ignore downward velocity since Agents never apply downward velocity
    -- themselves.
    velocity.y = 0;

    local maxSpeed = agent:GetMaxSpeed();
    local squaredSpeed = maxSpeed * maxSpeed;

    -- Using squared values avoids the cost of using the square
    -- root when calculating the magnitude of the velocity vector.
    if (Vector.LengthSquared(velocity) > squaredSpeed) then
        local newVelocity = Vector.Normalize(velocity) * maxSpeed;

        -- Reapply the original downward velocity after clamping.
        newVelocity.y = downwardVelocity;

        agent:SetVelocity(newVelocity);
    end
end

-- 为Agent创建胶囊体
function AgentUtilities_CreateAgentRepresentation(agent, height, radius)
    -- Capsule height and radius in meters.
    local capsule = Core.CreateCapsule(agent, height, radius);
    Core.SetMaterial(capsule, "Ground2");
end

function AgentUtilities_DrawLineToTarget(agent)
    Core.DrawLine(
            agent:GetPosition(), agent:GetTarget(), Vector.new(0, 1, 0));
end

function AgentUtilities_DrawTargetRadius(agent)
    Core.DrawCircle(
            agent:GetTarget(), agent:GetTargetRadius(), Vector.new(1, 0, 0));
end

function AgentUtilities_UpdatePosition(agent, deltaTimeInSeconds)
    -- Velocity(m/s) multiplied by seconds results in meters.
    local positionDelta = agent:GetVelocity() * deltaTimeInSeconds;

    -- Calculate the change in meters to the agents current position.
    local newPosition = agent:GetPosition() + positionDelta;

    -- Apply the change in position.
    agent:SetPosition(newPosition);
end
