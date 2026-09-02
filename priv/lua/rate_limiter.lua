-- KEYS[1]: Rate limit key (e.g., rate_limit:auth:login:email_5m:user@example.com)
-- ARGV[1]: Current timestamp in milliseconds
-- ARGV[2]: Window size in milliseconds (e.g., 60000)
-- ARGV[3]: Max allowed requests (e.g., 100)
-- ARGV[4]: Mode -> "check_only" or "hit" (default: "hit")

local key = KEYS[1]
local now = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local limit = tonumber(ARGV[3])
local mode = ARGV[4] or "hit"

local clear_before = now - window

-- 1. Remove expired records older than the sliding window
redis.call('ZREMRANGEBYSCORE', key, '-inf', '(' .. clear_before)

-- 2. Count requests remaining in the active window
local current_requests = redis.call('ZCARD', key)

-- 3. If in "check_only" mode, simply check if the count is below the limit
if mode == "check_only" then
    if current_requests < limit then
        return 1 -- Allow
    else
        return 0 -- Rate-limited
    end
end

-- 4. In the standard "hit" mode (record and evaluate):
if current_requests < limit then
    -- Limit not exceeded; record the current timestamp
    redis.call('ZADD', key, now, now)
    -- Update the key's expiration time to prevent the accumulation of stale data
    redis.call('PEXPIRE', key, window)
    return 1 -- Allow request
else
    return 0 -- Rate-limited
end
