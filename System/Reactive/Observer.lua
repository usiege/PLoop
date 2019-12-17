--===========================================================================--
--                                                                           --
--                         System.Reactive.Observer                          --
--                                                                           --
--===========================================================================--

--===========================================================================--
-- Author       :   kurapica125@outlook.com                                  --
-- URL          :   http://github.com/kurapica/PLoop                         --
-- Create Date  :   2019/12/01                                               --
-- Update Date  :   2019/12/01                                               --
-- Version      :   1.0.0                                                    --
--===========================================================================--

PLoop(function(_ENV)
    namespace "System.Reactive"

    __Sealed__() class "Observer" (function(_ENV)
        extend "System.IObserver"

        -----------------------------------------------------------------------
        --                          abstract method                          --
        -----------------------------------------------------------------------
        --- Provides the observer with new data
        __Abstract__() function OnNextCore(value) end

        --- Notifies the observer that the provider has experienced an error condition
        __Abstract__() function OnErrorCore(exception) end

        --- Notifies the observer that the provider has finished sending push-based notifications
        __Abstract__() function OnCompletedCore() end

        -----------------------------------------------------------------------
        --                              method                               --
        -----------------------------------------------------------------------
        --- Provides the observer with new data
        function OnNext(self, ...)
            if self.IsUnsubscribed then return end
            return self.OnNextCore(...)
        end

        --- Notifies the observer that the provider has experienced an error condition
        function OnError(self, exception)
            if self.IsUnsubscribed then return end
            self.IsUnsubscribed = true
            return self.OnErrorCore(exception)
        end

        --- Notifies the observer that the provider has finished sending push-based notifications
        function OnCompleted(self)
            if self.IsUnsubscribed then return end
            self.IsUnsubscribed = true
            return self.OnCompletedCore()
        end

        -----------------------------------------------------------------------
        --                            constructor                            --
        -----------------------------------------------------------------------
        __Arguments__{ Callable/nil, Callable/nil, Callable/nil }
        function __ctor(self, onNext, onError, onCompleted)
            self.OnNextCore     = onNext
            self.OnErrorCore    = onError
            self.OnCompletedCore= onCompleted
        end
    end)
end)