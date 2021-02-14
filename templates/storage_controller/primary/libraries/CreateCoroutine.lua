Thread = {
    threads = {},
    current = 1
}

function Thread.create(func)
    local t = {}
    t.co = coroutine.create(func)
    function t:stop()
        for i,th in pairs(Thread.threads) do
            if th == t then
                table.remove(Thread.threads, i)
            end
        end
    end
    table.insert(Thread.threads, t)
    return t
end
   
function Thread:run()
    while true do
        if #Thread.threads < 1 then
            return
        end
        if Thread.current > #Thread.threads then
            Thread.current = 1
        end
        coroutine.resume(true, Thread.threads[Thread.current].co)
        Thread.current = Thread.current + 1
    end
end