-- Match the parent directory
local path = (...):match('(.-)[^%./]+$')

return {
    name = 'event',
    description = 'Manages events, like keypresses.',
    functions = {
        {
            name = 'clear',
            description = 'Clears the event queue.',
            variants = {
                {}
            }
        },
        {
            name = 'poll',
            description = 'Returns an iterator for messages in the event queue.',
            variants = {
                {
                    returns = {
                        {
                            type = 'function',
                            name = 'i',
                            description = 'Iterator function usable in a for loop.'
                        }
                    }
                }
            }
        },
        {
            name = 'pump',
            description = 'Pump events into the event queue. This is a low-level function, and is usually not called by the user, but by love.run. Note that this does need to be called for any OS to think you\'re still running, and if you want to handle OS-generated events at all (think callbacks). love.event.pump can only be called from the main thread, but afterwards, the rest of love.event can be used from any other thread.',
            variants = {
                {}
            }
        },
        {
            name = 'push',
            description = 'Adds an event to the event queue.',
            variants = {
                {
                    arguments = {
                        {
                            type = 'Event',
                            name = 'e',
                            description = 'The name of the event.'
                        },
                        {
                            type = 'Variant',
                            name = 'a',
                            default = 'nil',
                            description = 'First event argument.'
                        },
                        {
                            type = 'Variant',
                            name = 'b',
                            default = 'nil',
                            description = 'Second event argument.'
                        },
                        {
                            type = 'Variant',
                            name = 'c',
                            default = 'nil',
                            description = 'Third event argument.'
                        },
                        {
                            type = 'Variant',
                            name = 'd',
                            default = 'nil',
                            description = 'Fourth event argument.'
                        }
                    }
                }
            }
        },
        {
            name = 'quit',
            description = 'Adds the quit event to the queue.\n\nThe quit event is a signal for the event handler to close LÖVE. It\'s possible to abort the exit process with the love.quit callback.',
            variants = {
                {},
                {
                    arguments = {
                        {
                            type = 'number',
                            name = 'exitstatus',
                            default = '0',
                            description = 'The program exit status to use when closing the application.'
                        }
                    }
                },
                {
                    arguments = {
                        {
                            type = 'string',
                            name = '"restart"',
                            description = 'Restarts the game without relaunching the executable. This cleanly shuts down the main Lua state instance and creates a brand new one.'
                        }
                    }
                }
            }
        },
        {
            name = 'wait',
            description = 'Like love.event.poll but blocks until there is an event in the queue.',
            variants = {
                {
                    returns = {
                        {
                            type = 'Event',
                            name = 'e',
                            description = 'The type of event.'
                        },
                        {
                            type = 'Variant',
                            name = 'a',
                            description = 'First event argument.'
                        },
                        {
                            type = 'Variant',
                            name = 'b',
                            description = 'Second event argument.'
                        },
                        {
                            type = 'Variant',
                            name = 'c',
                            description = 'Third event argument.'
                        },
                        {
                            type = 'Variant',
                            name = 'd',
                            description = 'Fourth event argument.'
                        }
                    }
                }
            }
        }
    },
    enums = {
        require(path .. 'enums.Event')
    }
}
