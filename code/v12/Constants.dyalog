:Namespace Constants
⍝ Dyalog constants
    :Namespace NINFO
        ⍝ left arguments
        NAME←0
        TYPE←1
        SIZE←2
        MODIFIED←3
        OWNER_USER_ID←4
        OWNER_NAME←5
        HIDDEN←6
        TARGET←7        
        :Namespace TYPES
			NOT_KNOWN←0
            DIRECTORY←1
            FILE←2
            CHARACTER_DEVICE←3
            SYMBOLIC_LINK←4
            BLOCK_DEVICE←5
            FIFO←6
            SOCKET←7			
        :EndNamespace
    :EndNamespace
    :Namespace NPUT
        OVERWRITE←1
    :EndNamespace
:EndNamespace