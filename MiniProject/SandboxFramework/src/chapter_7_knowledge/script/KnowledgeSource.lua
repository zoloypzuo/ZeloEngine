-- KnowledgeSource.lua
-- 2019年10月8日

-- 知识源
-- 代表一个需要复杂计算得到知识的源信息，数据
-- 缓存计算和更新
-- 复杂计算会被缓存，并按指定的频率重新计算
-- （AI的思考频率不必是每帧一次，但是像王者这样复杂紧张的战斗，频率要求可能比较高）
--
-- 计算置信度
-- 置信度是0~1的值，也就是概率，置信度高，说明AI应该更加相信它
KnowledgeSource = {};

function KnowledgeSource.Evaluate(self, userData)
    local time = Sandbox.GetTimeInMillis(userData.agent:GetSandbox());
    local nextUpdateTime = time + self.updateFrequency_;

    -- Wait till enough time has passed to re-evaluate the knowledge source.
    if (nextUpdateTime > self.lastUpdateTime_) then
        self.lastUpdateTime_ = time;
        local result = self.evaluator_(userData);
        self.confidence_ = result.confidence;
        self.evaluation_ = result.evaluation;
    end

    return { evaluation = self.evaluation_, confidence = self.confidence_ };
end

function KnowledgeSource.new(evaluator, updateFrequency)
    local source = {};

    -- The KnowledgeSource's data members.
    source.confidence_ = 0;
    source.evaluation_ = nil;
    source.evaluator_ = evaluator;
    source.lastUpdateTime_ = 0;
    source.updateFrequency_ = updateFrequency or 0;

    -- The KnowledgeSource's accessor functions.
    source.Evaluate = KnowledgeSource.Evaluate;

    return source;
end