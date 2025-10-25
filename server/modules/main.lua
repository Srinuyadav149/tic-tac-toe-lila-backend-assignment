local nk = require("nakama")
nk.logger_info("Hello World!")


local function get_data(context, payload)
    local message = "Hello, your id is " ..context.user_id .." your are " ..nk.json_decode(payload).user .." and your move is " ..nk.json_decode(payload).move
    nk.logger_info(message)
    return nk.json_encode({message = message})
end

local function authenticate_user(context, payload)
    local data = nk.json_decode(payload)
    local username = data.username
    local device_id = data.device_id

    local user_id, user_name, created = nk.authenticate_device(device_id, username, true)

    local message = created and "Created new User!" or "Welcome back User" ..user_id

    return nk.json_encode({
        user_id = user_id,
        user_name = user_name,
        created = created,
        message = message
    })
end

nk.register_rpc(get_data, "get_data")
nk.register_rpc(authenticate_user, "authenticate_user")