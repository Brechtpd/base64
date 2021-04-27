// SPDX-License-Identifier: MIT

/// @title Base64
/// @author Brecht Devos - <brecht@loopring.org>
/// @notice Provides a function for encoding some bytes in base64
contract Base64 {
    bytes internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) public pure returns (string memory) {
        if (data.length == 0) return '';

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(encodedLen + 32);
        
        // prepare the lookup table
        bytes memory table = TABLE;
        uint tablePtr;
        assembly {
            tablePtr := add(table, 1)
        }
        
        // input ptr
        uint dataPtr;
        assembly {
            dataPtr := data
        }
        uint endPtr = dataPtr + data.length;
        
        // result ptr, jump over length
        uint resultPtr = 32;
        assembly {
            resultPtr := add(result, 32)
        }
        
        // run over the input, 3 bytes at a time
        while(dataPtr < endPtr) {
            dataPtr += 3;
            assembly {
               // read 3 bytes
               let input := mload(dataPtr)
               
               // write 4 characters
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))
               resultPtr := add(resultPtr, 1)
            }
        }
        
        // padding
        uint r = data.length % 3;
        if (r != 0) {
            r = (r == 1) ? 2 : 1;
        }
        for (uint i = 0; i < r; i++) {
            result[encodedLen - 1 - i] = '=';
        }
        
        // Set the actual output length
        assembly {
            mstore(result, encodedLen)
        }

        return string(result);
    }
}
