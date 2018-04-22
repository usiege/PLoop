--===========================================================================--
--                                                                           --
--                     System.IO.Resource.IResourceLoader                    --
--                                                                           --
--===========================================================================--

--===========================================================================--
-- Author       :   kurapica125@outlook.com                                  --
-- URL          :   http://github.com/kurapica/PLoop                         --
-- Create Date  :   2016/01/28                                               --
-- Update Date  :   2018/03/16                                               --
-- Version      :   1.0.0                                                    --
--===========================================================================--

PLoop(function(_ENV)
    namespace "System.IO.Resource"

    --- The interface for the file loaders
    __Sealed__()
    interface "IResourceLoader" (function (_ENV)
        local _ResourceLoader       = {}

        export {
            type                    = type,
            strfind                 = string.find,
            strlower                = string.lower,
            safeset                 = Toolset.safeset,
            getsuffix               = IO.Path.GetSuffix,
            existfile               = IO.File.Exist,
            TryRunWithLock          = ILockManager.TryRunWithLock,
            RunWithLock             = ILockManager.RunWithLock,
        }

        -----------------------------------------------------------
        --                     static method                     --
        -----------------------------------------------------------
        --- Load the target resource
        -- @format  path
        -- @format  reader
        -- @param   path            the file path or a suffix to specific the type
        -- @param   reader          the text reader
        -- @param   trylock         whether only try run with the lock
        -- @return  resource        the resource generated by the file
        __Arguments__{ String, IO.TextReader/nil, Boolean/false }
        __Static__() function LoadResource(path, reader, trylock)
            local loader        = _ResourceLoader[strlower(getsuffix(path))]
            if not loader then return end
            if not reader and not existfile(path) then return end

            loader              = loader()
            return (trylock and TryRunWithLock or RunWithLock)("PLOOP_IRESOURCE_LOADER", loader.Load, loader, path, reader)
        end

        --- Register resource loader for suffix
        -- @param   loader          the resource loader
        -- @param   suffix          the file suffix
        __Arguments__{ - IResourceLoader, String }
        __Static__() function RegisterResourceLoader(loader, suffix)
            suffix      = strlower(suffix)
            if not strfind(suffix, "^%.") then
                suffix  = "." .. suffix
            end
            _ResourceLoader = safeset(_ResourceLoader, suffix, loader)
        end

        -----------------------------------------------------------
        --                         method                        --
        -----------------------------------------------------------
        --- Load the target resource from file path
        -- @param   path            the file path
        -- @param   reader          the text reader
        -- @return  resource        the resource generated by the file
        __Abstract__() function Load(self, path, reader) end

        -----------------------------------------------------------
        --                    static property                    --
        -----------------------------------------------------------
        --- the loader of suffix
        __Static__() __Indexer__()
        property "Loader" {
            get = function(_, suffix)
                if type(suffix) ~= "string" then return end
                suffix = strlower(suffix)
                if not strfind(suffix, "^%.") then suffix = "." .. suffix end
                return _ResourceLoader[suffix]
            end
        }
    end)

    --- The resource loader for specific suffix files to generate type features or others.
    __Final__() __Sealed__()
    class "__ResourceLoader__" (function (_ENV)
        extend "IAttachAttribute"

        export {
            tinsert             = table.insert,
            select              = select,
            ipairs              = ipairs,
            error               = error,

            Class, IResourceLoader,
        }

        -----------------------------------------------------------
        --                         method                        --
        -----------------------------------------------------------
        function AttachAttribute(self, target, targettype, owner, name, stack)
            if not Class.IsSubType(target, IResourceLoader) then
                error("the class must extend System.IO.IResourceLoader", stack + 1)
            end

            for _, v in ipairs(self) do
                IResourceLoader.RegisterResourceLoader(target, v)
            end
        end

        -----------------------------------------------------------
        --                       property                       --
        -----------------------------------------------------------
        --- the attribute target
        property "AttributeTarget"  { set = false, default = AttributeTargets.Class }

        -----------------------------------------------------------
        --                      constructor                      --
        -----------------------------------------------------------
        __Arguments__{ Variable.Rest(NEString) }
        function __new(_, ...)
            return { ... }, true
        end

        -----------------------------------------------------------
        --                      meta-method                      --
        -----------------------------------------------------------
        __Abstract__{ NEString }
        function __call(self, ...)
            for i = 1, select("#", ...) do
                tinsert(self, (select(i, ...)))
            end
        end
    end)
end)