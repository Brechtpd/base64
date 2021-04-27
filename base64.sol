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

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);
        
        bytes memory table = TABLE;
        uint tablePtr;
        assembly {
            tablePtr := add(table, 1)
        }
        
        uint outOffset = 32;
        for (uint i = 0; i < data.length;) {
            i += 3;
            uint input;
            assembly {
                input := and(mload(add(data, i)), 0xffffff)
            }
            
            assembly {
               let out := and(mload(add(tablePtr, and(shr(18, input), 0x3F))), 0xFF)
               out := shl(8, out)
               out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
               out := shl(8, out)
               out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
               out := shl(8, out)
               out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
               out := shl(224, out)
               
               mstore(add(result, outOffset), out)
            }
            outOffset += 4;
        }

        // Padding
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
