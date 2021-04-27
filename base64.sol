/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
contract Base64 {
    bytes internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) public pure returns (string memory) {
        uint256 bitLen = data.length * 8;
        if (bitLen == 0) return '';

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);
        bytes memory table = TABLE;
        
        uint outOffset = 32;
        for (uint i = 0; i < data.length;) {
            i += 3;
            uint input;
            assembly {
                input := and(mload(add(data, i)), 0xffffff)
            }
            
            uint offsetA = 1 + (input >> 3 * 6) & 0x3F;
            uint offsetB = 1 + (input >> 2 * 6) & 0x3F;
            uint offsetC = 1 + (input >> 1 * 6) & 0x3F;
            uint offsetD = 1 + (input >> 0 * 6) & 0x3F;
            assembly {
               let out := and(mload(add(table, offsetA)), 0xFF)
               out := shl(8, out)
               out := add(out, and(mload(add(table, offsetB)), 0xFF))
               out := shl(8, out)
               out := add(out, and(mload(add(table, offsetC)), 0xFF))
               out := shl(8, out)
               out := add(out, and(mload(add(table, offsetD)), 0xFF))
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
