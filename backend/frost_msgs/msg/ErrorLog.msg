uint8 dataID = 0        # frost_eth message type identifier - see https://wiki.frost-rover.com/basics/frost_eth
uint8 context           # application context ID - used for filtering
uint8 debugLevel        # debug, log, error, critical
uint8 dummy1            # dummy alignment byte (4 byte = 1 block in STM32)
uint8[60] message       # contains error code or informal text