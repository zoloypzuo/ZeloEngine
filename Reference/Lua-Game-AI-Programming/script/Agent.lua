-- Agent.lua
Agent = {}
--- @summary Metamethod that determines if the agent is equal to the other
---   variable.
--- @param agent Agent to compare.
--- @param variable Variable to compare against.
--- @return boolean True if the variable is equal to the agent.
--- @package Agent
--- @example comparison = agent == variable;
function Agent.__eq(agent)
end
function Agent.__index(agent)
end
function Agent.__towatch(agent)
end
--- @summary Apply a three dimensional force in meters to the agent.
--- @param agent Agent to apply force on.
--- @param vector Representing force in meters.
--- @package Agent
--- @example force = Agent.ApplyForce(agent, Vector.new(1, 0, 0));
function Agent.ApplyForce(agent)
end
--- @summary Calculate a force vector to steer the agent into aligning with
---   neighbor agents.
--- @param agent Agent to calculate a steering force for.
--- @param number Maximum distance to maintain with neighbors in meters.
--- @param number Maximum angle to maintain with neighbors in degrees.
--- @param table Table of agents indexed by number 1..n
--- @return vector Force vector in meters.
--- @package Agent
--- @example force = Agent.ForceToAlign(agent, 1, 90, { agent2, agent3 });
function Agent.ForceToAlign(agent)
end
--- @summary Calculate a force to avoid all other agents within the sandbox.
--- @param agent Agent to calculate avoidance force for.
--- @param number Optional time in seconds to predict future movements, defaults
---   to 0.1 seconds.
--- @return vector Force vector in meters.
--- @package Agent
--- @example force = Agent.ForceToAvoidAgents(agent);
--- @example force = Agent.ForceToAvoidAgents(agent, 1);
function Agent.ForceToAvoidAgents(agent)
end
--- @summary Calculate a force to avoid all movable objects within the sandbox.
--- @param agent Agent to calculate avoidance force for.
--- @param number Optional time in seconds to predict future movements, defaults
---   to 0.1 seconds.
--- @return vector Force vector in meters.
--- @package Agent
--- @example force = Agent.ForceToAvoidObjects(agent);
--- @example force = Agent.ForceToAvoidObjects(agent, 1);
function Agent.ForceToAvoidObjects(agent)
end
--- @summary Calculate a force vector to steer the agent into moving toward a
---   group of agents.
--- @param agent Agent to calculate a steering force for.
--- @param number Agents must be within this distance to be considered within the
---   group.
--- @param number Agents must be within this degree of difference to be
---   considered within the group.
--- @param table Table of agents indexed by number 1..n
--- @return vector Force vector in meters.
--- @package Agent
--- @example force = Agent.ForceToCombine(agent, 1, 90, { agent2, agent3 });
function Agent.ForceToCombine(agent)
end
--- @summary Calculate a force vector to steer the agent away from the position.
--- @param agent Agent to calculate a steering force for.
--- @param vector Position to steering away from.
--- @return vector Force vector in meters.
--- @package Agent
--- @example force = Agent.ForceToFleePosition(agent, vector.new(10, 0, 10));
function Agent.ForceToFleePosition(agent)
end
--- @summary Calculate a force vector to steer toward the Agent's current path.
---   If the Agent doesn't have a path, returns the zero vector.
--- @param agent Agent to calculate following force for.
--- @param number Optional time in seconds to predict future movements, defaults
---   to 0.1 seconds.
--- @return vector Force vector in meters.
--- @package Agent
--- @example force = Agent.ForceToFollowPath(agent);
--- @example force = Agent.ForceToFollowPath(agent, 1);
function Agent.ForceToFollowPath(agent)
end
--- @summary Calculate a force vector to steer the Agent's toward a position.
--- @param agent Agent to calculate seeking force for.
--- @param vector Position to steer towards.
--- @return vector Force vector in meters.
--- @package Agent
--- @example force = Agent.ForceToPosition(agent, Vector.new(10, 0, 10));
function Agent.ForceToPosition(agent)
end
--- @summary Calculate a force vector to steer away from a group of Agents.
--- @param agent Agent to calculate a separation force for.
--- @param number Agents must be within this distance to be considered within the
---   group.
--- @param number Agents must be within this degree of difference to be
---   considered within the group.
--- @param table Table of agents indexed by number 1..n
--- @return vector Force vector in meters.
--- @package Agent
--- @example force = Agent.ForceToSeparate(agent, 1, 90, { agent2, agent3 });
function Agent.ForceToSeparate(agent)
end
--- @summary Calculate a force vector to steer toward the Agent toward the
---   nearest path segment of their path.
--- @param agent Agent to calculate a separation force for.
--- @param number Optional time in seconds to predict future movements, defaults
---   to 0.1 seconds.
--- @return vector Force vector in meters.
--- @package Agent
--- @example force = Agent.ForceToStayOnPath(agent);
--- @example force = Agent.ForceToStayOnPath(agent, 1);
function Agent.ForceToStayOnPath(agent)
end
--- @summary Calculate a force vector to accelerate or decelerate the Agent to
---   the specified speed.
--- @param agent Agent to calculate a speed adjustment force for.
--- @param number Speed in meters for the Agent to match.
--- @return vector Force vector in meters.
--- @package Agent
--- @example force = Agent.ForceToTargetSpeed(agent, 3);
function Agent.ForceToTargetSpeed(agent)
end
--- @summary Calculate a force vector that randomly moves the agent in any
---   direction.  The delta time in milliseconds controls the magnitude of the
---   force vector.
--- @param agent Agent to calculate a force vector for.
--- @param number Delta time in milliseconds since the previous calling frame.
--- @return vector Force vector in meters.
--- @package Agent
--- @example force = Agent.ForceToWander(agent, deltaTimeInMillis);
function Agent.ForceToWander(agent)
end
function Agent.GetDistanceAlongPath(agent)
end
--- @summary Returns the forward axis of the Agent.
--- @param agent Agent to return the forward axis to.
--- @return vector Normalized forward vector.
--- @package Agent
--- @example forward = Agent.GetForward(agent);
function Agent.GetForward(agent)
end
--- @summary Returns the current health of the Agent.  Defaults to 100.
--- @param agent Agent to return the health of.
--- @return number Health of the Agent.
--- @package Agent
--- @example health = Agent.GetHealth(agent);
function Agent.GetHealth(agent)
end
--- @summary Returns the current height of the Agent.  Defaults to 1.6 meters.
--- @param agent Agent to return the height of.
--- @return number Height in meters.
--- @package Agent
--- @example height = Agent.GetHeight(agent);
function Agent.GetHeight(agent)
end
--- @summary Returns the unique id of the Agent.
--- @param agent Agent to return the id of.
--- @return number Unique id number.
--- @package Agent
--- @example id = Agent.GetId(agent);
function Agent.GetId(agent)
end
--- @summary Returns the left axis of the Agent.
--- @param agent Agent to return the left axis to.
--- @return vector Normalized left vector.
--- @package Agent
--- @example left = Agent.GetLeft(agent);
function Agent.GetLeft(agent)
end
--- @summary Returns the current mass of the Agent.  Defaults to 90.7 kilograms.
--- @param agent Agent to return the mass of.
--- @return number Mass of the Agent.
--- @package Agent
--- @example mass = Agent.GetMass(agent);
function Agent.GetMass(agent)
end
--- @summary Returns the maximum number of newtons the Agent's force vector can
---   reach.
--- @param agent Agent to return the maximum force of.
--- @return number Maximum force in number of newtons.
--- @package Agent
--- @example force = Agent.GetForce(agent);
function Agent.GetMaxForce(agent)
end
--- @summary Returns the maximum speed in meters per second the Agent can reach.
--- @param agent Agent to return the maximum speed of.
--- @return number Speed in meters per seconds.
--- @package Agent
--- @example speed = Agent.GetMaxSpeed(agent);
function Agent.GetMaxSpeed(agent)
end
function Agent.GetNearestPointOnPath(agent)
end
--- @summary Returns a table of vectors representing the current path of the
---   Agent.
--- @param agent Agent to return the path of.
--- @return table Table of vectors.  An empty table is returned if the Agent
---   has no path.
--- @package Agent
--- @example path = Agent.GetPath(agent);
function Agent.GetPath(agent)
end
function Agent.GetPointOnPath(agent)
end
--- @summary Returns the Agent's current position.  This is the Agent's
---   midpoint.
--- @param agent Agent to return the position of.
--- @return vector Position in meters.
--- @package Agent
--- @example position = Agent.GetPosition(agent);
function Agent.GetPosition(agent)
end
--- @summary Returns the Agent's current radius.  This is the Agent's capsule
---   radius used for avoidance and physics.
--- @param agent Agent to return the radius of.
--- @return number Radius in meters.
--- @package Agent
--- @example radius = Agent.GetRadius(agent);
function Agent.GetRadius(agent)
end
--- @summary Returns the Sandbox instance the Agent belongs to.
--- @param agent Agent to return the Sandbox from.
--- @return sandbox Sandbox instance.
--- @package Agent
--- @example sandbox = Agent.GetSandbox(agent);
function Agent.GetSandbox(agent)
end
--- @summary Returns the current speed of the agent as a scalar in meters per
---   second.
--- @param agent Agent to return the current speed of.
--- @return number Speed in meters per second.
--- @package Agent
--- @example speed = Agent.GetSpeed(agent);
function Agent.GetSpeed(agent)
end
--- @summary Returns the current target position of the agent in meters.
--- @param agent Agent to return the target of.
--- @return vector Position in meters.
--- @package Agent
--- @example target = Agent.GetTarget(agent);
function Agent.GetTarget(agent)
end
--- @summary Returns the current target radius of the agent in meters.  The
---   target radius is used to determine if the Agent is at the Agent's target
---   position.
--- @param agent Agent to return the target radius of.
--- @return number Target radius in meters.
--- @package Agent
--- @example targetRadius = Agent.GetTargetRadius(agent);
function Agent.GetTargetRadius(agent)
end
--- @summary Returns the current team name of the Agent, defaults to the empty
---   string.
--- @param agent Agent to return the team for.
--- @return string Team name.
--- @package Agent
--- @example team = Agent.GetTeam(agent);
function Agent.GetTeam(agent)
end
--- @summary Return the normalized up vector for the Agent.
--- @param agent Agent to return the up vector for.
--- @return vector Vector pointing in the up direction, normalized.
--- @package Agent
--- @example up = Agent.GetUp(agent);
function Agent.GetUp(agent)
end
--- @summary Returns the current velocity vector of the Agent.  The velocity
---   vector is the direction the Agent is moving and the magnitude of the vector
---   is the current speed of the Agent.  Velocity is measured in meters per
---   second.
--- @param agent Agent to return the velocity for.
--- @return vector Velocity vector in meters per second.
--- @package Agent
--- @example velocity = Agent.GetVelocity(agent);
function Agent.GetVelocity(agent)
end
function Agent.HasPath(agent)
end
function Agent.IsAgent(agent)
end
function Agent.PredictFuturePosition(agent)
end
function Agent.RemovePath(agent)
end
function Agent.RemovePhysics(agent)
end
function Agent.SetForward(agent)
end
function Agent.SetHealth(agent)
end
function Agent.SetHeight(agent)
end
function Agent.SetMass(agent)
end
function Agent.SetMaxForce(agent)
end
function Agent.SetMaxSpeed(agent)
end
function Agent.SetPath(agent)
end
function Agent.SetPosition(agent)
end
function Agent.SetRadius(agent)
end
function Agent.SetSpeed(agent)
end
function Agent.SetTarget(agent)
end
function Agent.SetTargetRadius(agent)
end
function Agent.SetTeam(agent)
end
function Agent.SetVelocity(agent)
end
return Agent