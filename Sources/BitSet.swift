//
//  BitSet.swift
//  Antlr.swift
//
//  Created by janyou on 15/9/8.
//  Copyright © 2015 jlabs. All rights reserved.
//

import Foundation


/**
* This class implements a vector of bits that grows as needed. Each
* component of the bit set has a {@code boolean} value. The
* bits of a {@code BitSet} are indexed by nonnegative integers.
* Individual indexed bits can be examined, set, or cleared. One
* {@code BitSet} may be used to modify the contents of another
* {@code BitSet} through logical AND, logical inclusive OR, and
* logical exclusive OR operations.
*
* <p>By default, all bits in the set initially have the value
* {@code false}.
*
* <p>Every bit set has a current size, which is the number of bits
* of space currently in use by the bit set. Note that the size is
* related to the implementation of a bit set, so it may change with
* implementation. The length of a bit set relates to logical length
* of a bit set and is defined independently of implementation.
*
* <p>Unless otherwise noted, passing a null parameter to any of the
* methods in a {@code BitSet} will result in a
* {@code NullPointerException}.
*
* <p>A {@code BitSet} is not safe for multithreaded use without
* external synchronization.
*
* @author  Arthur van Hoff
* @author  Michael McCloskey
* @author  Martin Buchholz
* @since   JDK1.0
*/

public class BitSet: Hashable, CustomStringConvertible {
    /*
    * BitSets are packed into arrays of "words."  Currently a word is
    * a long, which consists of 64 bits, requiring 6 address bits.
    * The choice of word size is determined purely by performance concerns.
    */
    private static let ADDRESS_BITS_PER_WORD: Int = 6
    private static let BITS_PER_WORD: Int = 1 << ADDRESS_BITS_PER_WORD
    private static let BIT_INDEX_MASK: Int = BITS_PER_WORD - 1

    /* Used to shift left or right for a partial word mask */
    private static let WORD_MASK: Int64 = Int64.max
    //0xfffffffffffffff//-1
    // 0xffffffffffffffffL;

    /**
    * @serialField bits long[]
    *
    * The bits in this BitSet.  The ith bit is stored in bits[i/64] at
    * bit position i % 64 (where bit position 0 refers to the least
    * significant bit and 63 refers to the most significant bit).
    */


    /**
    * The internal field corresponding to the serialField "bits".
    */
    private var words: [Int64]

    /**
    * The number of words in the logical size of this BitSet.
    */
    private var wordsInUse: Int = 0
    //transient

    /**
    * Whether the size of "words" is user-specified.  If so, we assume
    * the user knows what he's doing and try harder to preserve it.
    */
    private var sizeIsSticky: Bool = false
    //transient

    /* use serialVersionUID from JDK 1.0.2 for interoperability */
    private let serialVersionUID: Int64 = 7997698588986878753
    //L;

    /**
    * Given a bit index, return word index containing it.
    */
    private class func wordIndex(bitIndex: Int) -> Int {
        return bitIndex >> ADDRESS_BITS_PER_WORD
    }

    /**
    * Every public method must preserve these invariants.
    */
    private func checkInvariants() {
        assert((wordsInUse == 0 || words[wordsInUse - 1] != 0), "Expected: (wordsInUse==0||words[wordsInUse-1]!=0)")
        assert((wordsInUse >= 0 && wordsInUse <= words.count), "Expected: (wordsInUse>=0&&wordsInUse<=words.length)")
        // print("\(wordsInUse),\(words.count),\(words[wordsInUse])")
        assert((wordsInUse == words.count || words[wordsInUse] == 0), "Expected: (wordsInUse==words.count||words[wordsInUse]==0)")
    }

    /**
    * Sets the field wordsInUse to the logical size in words of the bit set.
    * WARNING:This method assumes that the number of words actually in use is
    * less than or equal to the current value of wordsInUse!
    */
    private func recalculateWordsInUse() {
        // Traverse the bitset until a used word is found
        var i: Int
        for i = wordsInUse - 1; i >= 0; i-- {
            if words[i] != 0 {
                break
            }
        }

        wordsInUse = i + 1 // The new logical size
    }

    /**
    * Creates a new bit set. All bits are initially {@code false}.
    */
    public init() {
        sizeIsSticky = false
        words = [Int64](count: BitSet.wordIndex(BitSet.BITS_PER_WORD - 1) + 1, repeatedValue: Int64(0))
        //initWords(BitSet.BITS_PER_WORD);

    }

    /**
    * Creates a bit set whose initial size is large enough to explicitly
    * represent bits with indices in the range {@code 0} through
    * {@code nbits-1}. All bits are initially {@code false}.
    *
    * @param  nbits the initial size of the bit set
    * @throws NegativeArraySizeException if the specified initial size
    *         is negative
    */
    public init(_ nbits: Int) throws {
        // nbits can't be negative; size 0 is OK

        // words = [BitSet.wordIndex(nbits-1) + 1];
        words = [Int64](count: BitSet.wordIndex(BitSet.BITS_PER_WORD - 1) + 1, repeatedValue: Int64(0))
        sizeIsSticky = true
        if nbits < 0 {
            throw ANTLRError.NegativeArraySize(msg: "nbits < 0:\(nbits) ")

        }
        // initWords(nbits);
    }

    private func initWords(nbits: Int) {
        // words =  [Int64](count: BitSet.wordIndex(BitSet.BITS_PER_WORD-1) + 1, repeatedValue: Int64(0));
        //  words = [BitSet.wordIndex(nbits-1) + 1];
    }

    /**
    * Creates a bit set using words as the internal representation.
    * The last word (if there is one) must be non-zero.
    */
    private init(_ words: [Int64]) {
        self.words = words
        self.wordsInUse = words.count
        checkInvariants()
    }


    /**
    * Returns a new long array containing all the bits in this bit set.
    *
    * <p>More precisely, if
    * <br>{@code long[] longs = s.toLongArray();}
    * <br>then {@code longs.length == (s.length()+63)/64} and
    * <br>{@code s.get(n) == ((longs[n/64] & (1L<<(n%64))) != 0)}
    * <br>for all {@code n < 64 * longs.length}.
    *
    * @return a long array containing a little-endian representation
    *         of all the bits in this bit set
    * @since 1.7
    */
    public func toLongArray() -> [Int64] {
        return copyOf(words, wordsInUse)
    }

    private func copyOf(words: [Int64], _ newLength: Int) -> [Int64] {
        var newWords = [Int64](count: newLength, repeatedValue: Int64(0))
        newWords[0 ..< min(words.count, newLength)] = words[0 ..< min(words.count, newLength)]
        return newWords
    }
    /**
    * Ensures that the BitSet can hold enough words.
    * @param wordsRequired the minimum acceptable number of words.
    */
    private func ensureCapacity(wordsRequired: Int) {
        if words.count < wordsRequired {
            // Allocate larger of doubled size or required size
            let request: Int = max(2 * words.count, wordsRequired)
            words = copyOf(words, request)
            sizeIsSticky = false
        }
    }

    /**
    * Ensures that the BitSet can accommodate a given wordIndex,
    * temporarily violating the invariants.  The caller must
    * restore the invariants before returning to the user,
    * possibly using recalculateWordsInUse().
    * @param wordIndex the index to be accommodated.
    */
    private func expandTo(wordIndex: Int) {
        let wordsRequired: Int = wordIndex + 1
        if wordsInUse < wordsRequired {
            ensureCapacity(wordsRequired)
            wordsInUse = wordsRequired
        }
    }

    /**
    * Checks that fromIndex ... toIndex is a valid range of bit indices.
    */
    private class func checkRange(fromIndex: Int, _ toIndex: Int) throws {
        if fromIndex < 0 {
            throw ANTLRError.IndexOutOfBounds(msg: "fromIndex < 0: \(fromIndex)")

        }

        if toIndex < 0 {
            throw ANTLRError.IndexOutOfBounds(msg: "toIndex < 0: \(toIndex)")

        }
        if fromIndex > toIndex {
            throw ANTLRError.IndexOutOfBounds(msg: "fromInde: \(fromIndex) > toIndex: \(toIndex)")

        }
    }

    /**
    * Sets the bit at the specified index to the complement of its
    * current value.
    *
    * @param  bitIndex the index of the bit to flip
    * @throws IndexOutOfBoundsException if the specified index is negative
    * @since  1.4
    */
    public func flip(bitIndex: Int) throws {
        if bitIndex < 0 {
            throw ANTLRError.IndexOutOfBounds(msg: "bitIndex < 0: \(bitIndex)")


        }
        let index: Int = BitSet.wordIndex(bitIndex)
        expandTo(index)

        words[index] ^= (Int64(1) << Int64(bitIndex % 64))

        recalculateWordsInUse()
        checkInvariants()
    }

    /**
    * Sets each bit from the specified {@code fromIndex} (inclusive) to the
    * specified {@code toIndex} (exclusive) to the complement of its current
    * value.
    *
    * @param  fromIndex index of the first bit to flip
    * @param  toIndex index after the last bit to flip
    * @throws IndexOutOfBoundsException if {@code fromIndex} is negative,
    *         or {@code toIndex} is negative, or {@code fromIndex} is
    *         larger than {@code toIndex}
    * @since  1.4
    */
    public func flip(fromIndex: Int, _ toIndex: Int) throws {
        try BitSet.checkRange(fromIndex, toIndex)

        if fromIndex == toIndex {
            return
        }

        let startWordIndex: Int = BitSet.wordIndex(fromIndex)
        let endWordIndex: Int = BitSet.wordIndex(toIndex - 1)
        expandTo(endWordIndex)

        let firstWordMask: Int64 = BitSet.WORD_MASK << Int64(fromIndex % 64)
        let lastWordMask: Int64 = BitSet.WORD_MASK >>> Int64(-toIndex)
        //var lastWordMask : Int64  = WORD_MASK >>> Int64(-toIndex);
        if startWordIndex == endWordIndex {
            // Case 1: One word
            words[startWordIndex] ^= (firstWordMask & lastWordMask)
        } else {
            // Case 2: Multiple words
            // Handle first word
            words[startWordIndex] ^= firstWordMask

            // Handle intermediate words, if any
            for var i: Int = startWordIndex + 1; i < endWordIndex; i++ {
                words[i] ^= BitSet.WORD_MASK
            }

            // Handle last word
            words[endWordIndex] ^= lastWordMask
        }

        recalculateWordsInUse()
        checkInvariants()
    }

    /**
    * Sets the bit at the specified index to {@code true}.
    *
    * @param  bitIndex a bit index
    * @throws IndexOutOfBoundsException if the specified index is negative
    * @since  JDK1.0
    */
    public func set(bitIndex: Int) throws {
        if bitIndex < 0 {
            throw ANTLRError.IndexOutOfBounds(msg: "bitIndex < 0: \(bitIndex)")

        }
        let index: Int = BitSet.wordIndex(bitIndex)
        expandTo(index)

        // print(words.count)
        words[index] |= (Int64(1) << Int64(bitIndex % 64))  // Restores invariants

        checkInvariants()
    }

    /**
    * Sets the bit at the specified index to the specified value.
    *
    * @param  bitIndex a bit index
    * @param  value a boolean value to set
    * @throws IndexOutOfBoundsException if the specified index is negative
    * @since  1.4
    */
    public func set(bitIndex: Int, _ value: Bool) throws {
        if value {
            try set(bitIndex)
        } else {
            try clear(bitIndex)
        }
    }

    /**
    * Sets the bits from the specified {@code fromIndex} (inclusive) to the
    * specified {@code toIndex} (exclusive) to {@code true}.
    *
    * @param  fromIndex index of the first bit to be set
    * @param  toIndex index after the last bit to be set
    * @throws IndexOutOfBoundsException if {@code fromIndex} is negative,
    *         or {@code toIndex} is negative, or {@code fromIndex} is
    *         larger than {@code toIndex}
    * @since  1.4
    */
    public func set(fromIndex: Int, _ toIndex: Int) throws {
        try BitSet.checkRange(fromIndex, toIndex)

        if fromIndex == toIndex {
            return
        }

        // Increase capacity if necessary
        let startWordIndex: Int = BitSet.wordIndex(fromIndex)
        let endWordIndex: Int = BitSet.wordIndex(toIndex - 1)
        expandTo(endWordIndex)

        let firstWordMask: Int64 = BitSet.WORD_MASK << Int64(fromIndex % 64)
        let lastWordMask: Int64 = BitSet.WORD_MASK >>> Int64(-toIndex)
        //var lastWordMask : Int64  = WORD_MASK >>>Int64( -toIndex);
        if startWordIndex == endWordIndex {
            // Case 1: One word
            words[startWordIndex] |= (firstWordMask & lastWordMask)
        } else {
            // Case 2: Multiple words
            // Handle first word
            words[startWordIndex] |= firstWordMask

            // Handle intermediate words, if any
            for var i: Int = startWordIndex + 1; i < endWordIndex; i++ {
                words[i] = BitSet.WORD_MASK
            }

            // Handle last word (restores invariants)
            words[endWordIndex] |= lastWordMask
        }

        checkInvariants()
    }

    /**
    * Sets the bits from the specified {@code fromIndex} (inclusive) to the
    * specified {@code toIndex} (exclusive) to the specified value.
    *
    * @param  fromIndex index of the first bit to be set
    * @param  toIndex index after the last bit to be set
    * @param  value value to set the selected bits to
    * @throws IndexOutOfBoundsException if {@code fromIndex} is negative,
    *         or {@code toIndex} is negative, or {@code fromIndex} is
    *         larger than {@code toIndex}
    * @since  1.4
    */
    public func set(fromIndex: Int, _ toIndex: Int, _ value: Bool) throws {
        if value {
            try set(fromIndex, toIndex)
        } else {
            try clear(fromIndex, toIndex)
        }
    }

    /**
    * Sets the bit specified by the index to {@code false}.
    *
    * @param  bitIndex the index of the bit to be cleared
    * @throws IndexOutOfBoundsException if the specified index is negative
    * @since  JDK1.0
    */
    public func clear(bitIndex: Int) throws {
        if bitIndex < 0 {
            throw ANTLRError.IndexOutOfBounds(msg: "bitIndex < 0: \(bitIndex)")


        }
        let index: Int = BitSet.wordIndex(bitIndex)
        if index >= wordsInUse {
            return
        }

        words[index] &= ~(Int64(1) << Int64(bitIndex % 64))

        recalculateWordsInUse()
        checkInvariants()
    }

    /**
    * Sets the bits from the specified {@code fromIndex} (inclusive) to the
    * specified {@code toIndex} (exclusive) to {@code false}.
    *
    * @param  fromIndex index of the first bit to be cleared
    * @param  toIndex index after the last bit to be cleared
    * @throws IndexOutOfBoundsException if {@code fromIndex} is negative,
    *         or {@code toIndex} is negative, or {@code fromIndex} is
    *         larger than {@code toIndex}
    * @since  1.4
    */
    public func clear(fromIndex: Int, _ toIndex: Int) throws {
        var toIndex = toIndex
        try BitSet.checkRange(fromIndex, toIndex)

        if fromIndex == toIndex {
            return
        }

        let startWordIndex: Int = BitSet.wordIndex(fromIndex)
        if startWordIndex >= wordsInUse {
            return
        }

        var endWordIndex: Int = BitSet.wordIndex(toIndex - 1)
        if endWordIndex >= wordsInUse {
            toIndex = length()
            endWordIndex = wordsInUse - 1
        }

        let firstWordMask: Int64 = BitSet.WORD_MASK << Int64(fromIndex % 64)
        // ar lastWordMask : Int64  = WORD_MASK >>> Int64((-toIndex);
        let lastWordMask: Int64 = BitSet.WORD_MASK >>> Int64(-toIndex)
        if startWordIndex == endWordIndex {
            // Case 1: One word
            words[startWordIndex] &= ~(firstWordMask & lastWordMask)
        } else {
            // Case 2: Multiple words
            // Handle first word
            words[startWordIndex] &= ~firstWordMask

            // Handle intermediate words, if any
            for var i: Int = startWordIndex + 1; i < endWordIndex; i++ {
                words[i] = 0
            }

            // Handle last word
            words[endWordIndex] &= ~lastWordMask
        }

        recalculateWordsInUse()
        checkInvariants()
    }

    /**
    * Sets all of the bits in this BitSet to {@code false}.
    *
    * @since 1.4
    */
    public func clear() {
        while wordsInUse > 0 {
            words[--wordsInUse] = 0
        }
    }

    /**
    * Returns the value of the bit with the specified index. The value
    * is {@code true} if the bit with the index {@code bitIndex}
    * is currently set in this {@code BitSet}; otherwise, the result
    * is {@code false}.
    *
    * @param  bitIndex   the bit index
    * @return the value of the bit with the specified index
    * @throws IndexOutOfBoundsException if the specified index is negative
    */
    public func get(bitIndex: Int) throws -> Bool {
        if bitIndex < 0 {
            throw ANTLRError.IndexOutOfBounds(msg: "bitIndex < 0: \(bitIndex)")

        }
        checkInvariants()

        let index: Int = BitSet.wordIndex(bitIndex)

        return (index < wordsInUse)
                && ((words[index] & ((Int64(1) << Int64(bitIndex % 64)))) != 0)
    }

    /**
    * Returns a new {@code BitSet} composed of bits from this {@code BitSet}
    * from {@code fromIndex} (inclusive) to {@code toIndex} (exclusive).
    *
    * @param  fromIndex index of the first bit to include
    * @param  toIndex index after the last bit to include
    * @return a new {@code BitSet} from a range of this {@code BitSet}
    * @throws IndexOutOfBoundsException if {@code fromIndex} is negative,
    *         or {@code toIndex} is negative, or {@code fromIndex} is
    *         larger than {@code toIndex}
    * @since  1.4
    */
    public func get(fromIndex: Int, _ toIndex: Int) throws -> BitSet {
        var toIndex = toIndex
        try  BitSet.checkRange(fromIndex, toIndex)

        checkInvariants()

        let len: Int = length()

        // If no set bits in range return empty bitset
        if len <= fromIndex || fromIndex == toIndex {
            return try  BitSet(0)
        }

        // An optimization
        if toIndex > len {
            toIndex = len
        }

        let result: BitSet = try BitSet(toIndex - fromIndex)
        let targetWords: Int = BitSet.wordIndex(toIndex - fromIndex - 1) + 1
        var sourceIndex: Int = BitSet.wordIndex(fromIndex)
        let wordAligned: Bool = (fromIndex & BitSet.BIT_INDEX_MASK) == 0

        // Process all words but the last word
        for var i: Int = 0; i < targetWords - 1; i++, sourceIndex++ {
            result.words[i] = wordAligned ? words[sourceIndex] :
                    //(words[sourceIndex] >>> fromIndex) |
                    (words[sourceIndex] >>> Int64(fromIndex)) |
                    (words[sourceIndex + 1] << Int64(-fromIndex % 64))
        }
        // Process the last word
        // var lastWordMask : Int64 = WORD_MASK >>> Int64(-toIndex);
        let lastWordMask: Int64 = BitSet.WORD_MASK >>> Int64(-toIndex)
        result.words[targetWords - 1] =
                ((toIndex - 1) & BitSet.BIT_INDEX_MASK) < (fromIndex & BitSet.BIT_INDEX_MASK)
                ? /* straddles source words */
                // ((words[sourceIndex] >>> fromIndex) |
                ((words[sourceIndex] >>> Int64(fromIndex)) |
                        (words[sourceIndex + 1] & lastWordMask) << (64 + Int64(-fromIndex % 64)))
                :
                // ((words[sourceIndex] & lastWordMask) >>> fromIndex);
                ((words[sourceIndex] & lastWordMask) >>> Int64(fromIndex))
        // Set wordsInUse correctly
        result.wordsInUse = targetWords

        result.recalculateWordsInUse()
        result.checkInvariants()

        return result
    }

    /**
    * Returns the index of the first bit that is set to {@code true}
    * that occurs on or after the specified starting index. If no such
    * bit exists then {@code -1} is returned.
    *
    * <p>To iterate over the {@code true} bits in a {@code BitSet},
    * use the following loop:
    *
    *  <pre> {@code
    * for (int i = bs.nextSetBit(0); i >= 0; i = bs.nextSetBit(i+1)) {
    *     // operate on index i here
    * }}</pre>
    *
    * @param  fromIndex the index to start checking from (inclusive)
    * @return the index of the next set bit, or {@code -1} if there
    *         is no such bit
    * @throws IndexOutOfBoundsException if the specified index is negative
    * @since  1.4
    */
    public func nextSetBit(fromIndex: Int) throws -> Int {
        if fromIndex < 0 {
            throw ANTLRError.IndexOutOfBounds(msg: "fromIndex < 0: \(fromIndex)")

        }
        checkInvariants()

        var u: Int = BitSet.wordIndex(fromIndex)
        if u >= wordsInUse {
            return -1
        }

        var word: Int64 = words[u] & (BitSet.WORD_MASK << Int64(fromIndex % 64))

        while true {
            if word != 0 {
                let bit = (u * BitSet.BITS_PER_WORD) + BitSet.numberOfTrailingZeros(word)
                return bit
            }
            if ++u == wordsInUse {
                return -1
            }
            word = words[u]
        }
    }

    public class func numberOfTrailingZeros(i: Int64) -> Int {
        // HD, Figure 5-14
        var x: Int32, y: Int32
        if i == 0 {
            return 64
        }
        var n: Int32 = 63
        y = Int32(i)
        if y != 0 {
            n = n - 32
            x = y
        } else {
            x = Int32(i >>> 32)
        }

        y = x << 16
        if y != 0 {
            n = n - 16
            x = y
        }
        y = x << 8
        if y != 0 {
            n = n - 8
            x = y
        }
        y = x << 4
        if y != 0 {
            n = n - 4
            x = y
        }
        y = x << 2
        if y != 0 {
            n = n - 2
            x = y
        }
        return n - ((x << 1) >>> 31)
    }

    /**
    * Returns the index of the first bit that is set to {@code false}
    * that occurs on or after the specified starting index.
    *
    * @param  fromIndex the index to start checking from (inclusive)
    * @return the index of the next clear bit
    * @throws IndexOutOfBoundsException if the specified index is negative
    * @since  1.4
    */
    public func nextClearBit(fromIndex: Int) throws -> Int {
        // Neither spec nor implementation handle bitsets of maximal length.
        // See 4816253.
        if fromIndex < 0 {
            throw ANTLRError.IndexOutOfBounds(msg: "fromIndex < 0: \(fromIndex)")

        }
        checkInvariants()

        var u: Int = BitSet.wordIndex(fromIndex)
        if u >= wordsInUse {
            return fromIndex
        }

        var word: Int64 = ~words[u] & (BitSet.WORD_MASK << Int64(fromIndex % 64))

        while true {
            if word != 0 {
                return (u * BitSet.BITS_PER_WORD) + BitSet.numberOfTrailingZeros(word)
            }
            if ++u == wordsInUse {
                return wordsInUse * BitSet.BITS_PER_WORD
            }
            word = ~words[u]
        }
    }

    /**
    * Returns the index of the nearest bit that is set to {@code true}
    * that occurs on or before the specified starting index.
    * If no such bit exists, or if {@code -1} is given as the
    * starting index, then {@code -1} is returned.
    *
    * <p>To iterate over the {@code true} bits in a {@code BitSet},
    * use the following loop:
    *
    *  <pre> {@code
    * for (int i = bs.length(); (i = bs.previousSetBit(i-1)) >= 0; ) {
    *     // operate on index i here
    * }}</pre>
    *
    * @param  fromIndex the index to start checking from (inclusive)
    * @return the index of the previous set bit, or {@code -1} if there
    *         is no such bit
    * @throws IndexOutOfBoundsException if the specified index is less
    *         than {@code -1}
    * @since  1.7
    */
    public func previousSetBit(fromIndex: Int) throws -> Int {
        if fromIndex < 0 {
            if fromIndex == -1 {
                return -1
            }
            throw ANTLRError.IndexOutOfBounds(msg: "fromIndex < -1: \(fromIndex)")

        }

        checkInvariants()

        var u: Int = BitSet.wordIndex(fromIndex)
        if u >= wordsInUse {
            return length() - 1
        }

        var word: Int64 = words[u] & (BitSet.WORD_MASK >>> Int64(-(fromIndex + 1)))
        while true {
            if word != 0 {
                return (u + 1) * BitSet.BITS_PER_WORD - 1 - BitSet.numberOfLeadingZeros(word)
            }
            if u-- == 0 {
                return -1
            }
            word = words[u]
        }
    }

    /**
    * Returns the index of the nearest bit that is set to {@code false}
    * that occurs on or before the specified starting index.
    * If no such bit exists, or if {@code -1} is given as the
    * starting index, then {@code -1} is returned.
    *
    * @param  fromIndex the index to start checking from (inclusive)
    * @return the index of the previous clear bit, or {@code -1} if there
    *         is no such bit
    * @throws IndexOutOfBoundsException if the specified index is less
    *         than {@code -1}
    * @since  1.7
    */
    public func previousClearBit(fromIndex: Int) throws -> Int {
        if fromIndex < 0 {
            if fromIndex == -1 {
                return -1
            }
            throw ANTLRError.IndexOutOfBounds(msg: "fromIndex < -1: \(fromIndex)")

        }

        checkInvariants()

        var u: Int = BitSet.wordIndex(fromIndex)
        if u >= wordsInUse {
            return fromIndex
        }

        var word: Int64 = ~words[u] & (BitSet.WORD_MASK >>> Int64(-(fromIndex + 1)))
        // var word : Int64 = ~words[u] & (WORD_MASK >>> -(fromIndex+1));

        while true {
            if word != 0 {
                return (u + 1) * BitSet.BITS_PER_WORD - 1 - BitSet.numberOfLeadingZeros(word)
            }
            if u-- == 0 {
                return -1
            }
            word = ~words[u]
        }
    }

    public class func numberOfLeadingZeros(i: Int64) -> Int {
        // HD, Figure 5-6
        if i == 0 {
            return 64
        }
        var n: Int32 = 1
        var x = Int32(i >>> 32)
        if x == 0 {
            n += 32
            x = Int32(i)
        }
        if x >>> 16 == 0 {
            n += 16
            x <<= 16
        }
        if x >>> 24 == 0 {
            n += 8
            x <<= 8
        }
        if x >>> 28 == 0 {
            n += 4
            x <<= 4
        }
        if x >>> 30 == 0 {
            n += 2
            x <<= 2
        }
        n -= x >>> 31

        return Int(n)
    }
    /**
    * Returns the "logical size" of this {@code BitSet}: the index of
    * the highest set bit in the {@code BitSet} plus one. Returns zero
    * if the {@code BitSet} contains no set bits.
    *
    * @return the logical size of this {@code BitSet}
    * @since  1.2
    */
    public func length() -> Int {
        if wordsInUse == 0 {
            return 0
        }

        return BitSet.BITS_PER_WORD * (wordsInUse - 1) +
                (BitSet.BITS_PER_WORD - BitSet.numberOfLeadingZeros(words[wordsInUse - 1]))
    }

    /**
    * Returns true if this {@code BitSet} contains no bits that are set
    * to {@code true}.
    *
    * @return boolean indicating whether this {@code BitSet} is empty
    * @since  1.4
    */
    public func isEmpty() -> Bool {
        return wordsInUse == 0
    }

    /**
    * Returns true if the specified {@code BitSet} has any bits set to
    * {@code true} that are also set to {@code true} in this {@code BitSet}.
    *
    * @param  set {@code BitSet} to intersect with
    * @return boolean indicating whether this {@code BitSet} intersects
    *         the specified {@code BitSet}
    * @since  1.4
    */
    public func intersects(set: BitSet) -> Bool {
        for var i: Int = min(wordsInUse, set.wordsInUse) - 1; i >= 0; i-- {
            if (words[i] & set.words[i]) != 0 {
                return true
            }
        }
        return false
    }

    /**
    * Returns the number of bits set to {@code true} in this {@code BitSet}.
    *
    * @return the number of bits set to {@code true} in this {@code BitSet}
    * @since  1.4
    */
    public func cardinality() -> Int {
        var sum: Int = 0
        for var i: Int = 0; i < wordsInUse; i++ {
            sum += BitSet.bitCount(words[i])
        }
        return sum
    }

    public class func bitCount(i: Int64) -> Int {
        var i = i
        // HD, Figure 5-14
        i = i - ((i >>> 1) & 0x5555555555555555)
        i = (i & 0x3333333333333333) + ((i >>> 2) & 0x3333333333333333)
        i = (i + (i >>> 4)) & 0x0f0f0f0f0f0f0f0f
        i = i + (i >>> 8)
        i = i + (i >>> 16)
        i = i + (i >>> 32)

        return Int(Int32(i) & 0x7f)
    }

    /**
    * Performs a logical <b>AND</b> of this target bit set with the
    * argument bit set. This bit set is modified so that each bit in it
    * has the value {@code true} if and only if it both initially
    * had the value {@code true} and the corresponding bit in the
    * bit set argument also had the value {@code true}.
    *
    * @param set a bit set
    */
    public func and(set: BitSet) {
        if self == set {
            return
        }

        while wordsInUse > set.wordsInUse {
            words[--wordsInUse] = 0
        }

        // Perform logical AND on words in common
        for var i: Int = 0; i < wordsInUse; i++ {
            words[i] &= set.words[i]
        }

        recalculateWordsInUse()
        checkInvariants()
    }

    /**
    * Performs a logical <b>OR</b> of this bit set with the bit set
    * argument. This bit set is modified so that a bit in it has the
    * value {@code true} if and only if it either already had the
    * value {@code true} or the corresponding bit in the bit set
    * argument has the value {@code true}.
    *
    * @param set a bit set
    */
    public func or(set: BitSet) {
        if self == set {
            return
        }

        let wordsInCommon: Int = min(wordsInUse, set.wordsInUse)

        if wordsInUse < set.wordsInUse {
            ensureCapacity(set.wordsInUse)
            wordsInUse = set.wordsInUse
        }

        // Perform logical OR on words in common
        for var i: Int = 0; i < wordsInCommon; i++ {
            words[i] |= set.words[i]
        }

        // Copy any remaining words
        if wordsInCommon < set.wordsInUse {
            words[wordsInCommon ..< wordsInUse] = set.words[wordsInCommon ..< wordsInUse]

        }

        // recalculateWordsInUse() is unnecessary
        checkInvariants()
    }

    /**
    * Performs a logical <b>XOR</b> of this bit set with the bit set
    * argument. This bit set is modified so that a bit in it has the
    * value {@code true} if and only if one of the following
    * statements holds:
    * <ul>
    * <li>The bit initially has the value {@code true}, and the
    *     corresponding bit in the argument has the value {@code false}.
    * <li>The bit initially has the value {@code false}, and the
    *     corresponding bit in the argument has the value {@code true}.
    * </ul>
    *
    * @param  set a bit set
    */
    public func xor(set: BitSet) {
        let wordsInCommon: Int = min(wordsInUse, set.wordsInUse)

        if wordsInUse < set.wordsInUse {
            ensureCapacity(set.wordsInUse)
            wordsInUse = set.wordsInUse
        }

        // Perform logical XOR on words in common
        for var i: Int = 0; i < wordsInCommon; i++ {
            words[i] ^= set.words[i]
        }

        // Copy any remaining words
        if wordsInCommon < set.wordsInUse {
            words[wordsInCommon ..< wordsInUse] = set.words[wordsInCommon ..< wordsInUse]


        }

        recalculateWordsInUse()
        checkInvariants()
    }

    /**
    * Clears all of the bits in this {@code BitSet} whose corresponding
    * bit is set in the specified {@code BitSet}.
    *
    * @param  set the {@code BitSet} with which to mask this
    *         {@code BitSet}
    * @since  1.2
    */
    public func andNot(set: BitSet) {
        // Perform logical (a & !b) on words in common
        for var i: Int = min(wordsInUse, set.wordsInUse) - 1; i >= 0; i-- {
            words[i] &= ~set.words[i]
        }

        recalculateWordsInUse()
        checkInvariants()
    }

    /**
    * Returns the hash code value for this bit set. The hash code depends
    * only on which bits are set within this {@code BitSet}.
    *
    * <p>The hash code is defined to be the result of the following
    * calculation:
    *  <pre> {@code
    * public int hashCode() {
    *     long h = 1234;
    *     long[] words = toLongArray();
    *     for (int i = words.length; --i >= 0; )
    *         h ^= words[i] * (i + 1);
    *     return (int)((h >> 32) ^ h);
    * }}</pre>
    * Note that the hash code changes if the set of bits is altered.
    *
    * @return the hash code value for this bit set
    */
    public var hashValue: Int {
        var h: Int64 = 1234
        for var i: Int = wordsInUse; --i >= 0;
        {
            h ^= words[i] * (i + 1)
        }

        return Int(Int32((h >> 32) ^ h))
    }

    /**
    * Returns the number of bits of space actually in use by this
    * {@code BitSet} to represent bit values.
    * The maximum element in the set is the size - 1st element.
    *
    * @return the number of bits currently in this bit set
    */
    public func size() -> Int {
        return words.count * BitSet.BITS_PER_WORD
    }





    /**
    * Attempts to reduce internal storage used for the bits in this bit set.
    * Calling this method may, but is not required to, affect the value
    * returned by a subsequent call to the {@link #size()} method.
    */
    private func trimToSize() {
        if wordsInUse != words.count {
            words = copyOf(words, wordsInUse)
            checkInvariants()
        }
    }


    /**
    * Returns a string representation of this bit set. For every index
    * for which this {@code BitSet} contains a bit in the set
    * state, the decimal representation of that index is included in
    * the result. Such indices are listed in order from lowest to
    * highest, separated by ",&nbsp;" (a comma and a space) and
    * surrounded by braces, resulting in the usual mathematical
    * notation for a set of integers.
    *
    * <p>Example:
    * <pre>
    * BitSet drPepper = new BitSet();</pre>
    * Now {@code drPepper.toString()} returns "{@code {}}".
    * <pre>
    * drPepper.set(2);</pre>
    * Now {@code drPepper.toString()} returns "{@code {2}}".
    * <pre>
    * drPepper.set(4);
    * drPepper.set(10);</pre>
    * Now {@code drPepper.toString()} returns "{@code {2, 4, 10}}".
    *
    * @return a string representation of this bit set
    */
    public var description: String {
        checkInvariants()

        //let numBits: Int = (wordsInUse > 128) ?
        // cardinality() : wordsInUse * BitSet.BITS_PER_WORD
        let b: StringBuilder = StringBuilder()
        b.append("{")
        do {
            var i: Int = try  nextSetBit(0)
            if i != -1 {
                b.append(i)
                for i = try  nextSetBit(i + 1); i >= 0; i = try nextSetBit(i + 1) {
                    let endOfRun: Int = try  nextClearBit(i)
                    repeat {
                        b.append(", ").append(i)
                    } while ++i < endOfRun
                }
            }
        } catch {
            print("BitSet description error")
        }
        b.append("}")
        return b.toString()

    }
    public func toString() -> String {
        return description
    }

}

public func ==(lhs: BitSet, rhs: BitSet) -> Bool {

    if lhs === rhs {
        return true
    }


    lhs.checkInvariants()
    rhs.checkInvariants()

    if lhs.wordsInUse != rhs.wordsInUse {
        return false
    }

    // Check words in use by both BitSets
    for var i: Int = 0; i < lhs.wordsInUse; i++ {
        if lhs.words[i] != rhs.words[i] {
            return false
        }
    }

    return true

}