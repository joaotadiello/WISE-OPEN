// Will return whether the current environment is in a regular browser
// and not CEF
export const isEnvBrowser = () => !(window).invokeNative

// Basic no operation function
export const noop = () => {}

export const debugData = (events, timer) => {
    if (isEnvBrowser()) {
        for (const event of events) {
            setTimeout(() => {
                window.dispatchEvent(
                    new MessageEvent('message', {
                        data: {
                            action: event.action,
                            data: event.data
                        }
                    })
                )
            }, timer)
        }
    }
}
