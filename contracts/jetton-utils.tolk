import "@stdlib/tvm-dicts"
import "workchain.tolk"
import "op-codes.tolk"

const STATUS_SIZE = 4;
const SHARD_DEPTH = 8;

@inline
fun packJettonWalletData(status: int, balance: int, ownerAddress: slice, jettonMasterAddress: slice): cell {
    return beginCell()
    .storeUint(status, STATUS_SIZE)
    .storeCoins(balance)
    .storeSlice(ownerAddress)
    .storeSlice(jettonMasterAddress)
    .endCell();
}

@inline fun getAddressShard(address: slice, shardLen: int) {
    // Skip workchain, load shard prefix
    return address.skipBits(3 + 8).loadUint(shardLen);
}

@inline
fun calculateJettonWalletStateInit(ownerAddress: slice, jettonMasterAddress: slice, jettonWalletCode: cell): cell {
    /*
    https://github.com/ton-blockchain/ton/blob/8a9ff339927b22b72819c5125428b70c406da631/crypto/block/block.tlb#L144
    _ split_depth:(Maybe (## 5)) special:(Maybe TickTock)
    code:(Maybe ^Cell) data:(Maybe ^Cell)
    library:(Maybe ^Cell) = StateInit;
  */
    return beginCell()
    // Compilator would take care of storeUint optimization, right?
    .storeUint(1, 1)
    .storeUint(SHARD_DEPTH, 5)
    .storeUint(0, 1)
    .storeMaybeRef(jettonWalletCode)
    .storeMaybeRef(
        packJettonWalletData(
            0, // status
            0, // balance
            ownerAddress,
            jettonMasterAddress)
    )
    .storeUint(0, 1) // Empty libraries
    .endCell();
}

@inline
fun calculateJettonWalletAddress(ownerShard: int, stateInit: cell): slice {
    /*
    https://github.com/ton-blockchain/ton/blob/8a9ff339927b22b72819c5125428b70c406da631/crypto/block/block.tlb#L105
    addr_std$10 anycast:(Maybe Anycast) workchain_id:int8 address:bits256  = MsgAddressInt;
    */
    var mask = (1 << (256 - SHARD_DEPTH)) - 1;
    var prefixLess = stateInit.hash() & mask;
    return beginCell()
    .storeUint(4, 3) // 0b100 = addr_std$10 tag; No anycast
    .storeInt(MY_WORKCHAIN, 8)
    .storeUint(ownerShard, SHARD_DEPTH)
    .storeUint(prefixLess, 256 - SHARD_DEPTH)
    // .storeUint((ownerShard << (256 - SHARD_DEPTH)) | (cellHash(stateInit) << SHARD_DEPTH), 256)
    .endCell()
    .beginParse();
}

@inline
fun calculateUserJettonWalletAddress(ownerAddress: slice, jettonMasterAddress: slice, jettonWalletCode: cell): slice {
    var shardPrefix = getAddressShard(ownerAddress, SHARD_DEPTH);
    return calculateJettonWalletAddress(shardPrefix, calculateJettonWalletStateInit(ownerAddress, jettonMasterAddress, jettonWalletCode));
}

@inline
fun checkEitherForwardPayload(s: slice) {
    if (s.preloadUint(1)) {
        // forward_payload in ref
        var (remainBits: int, remainRefs: int) = s.remainingBitsAndRefsCount();
        assert((remainRefs == 1) & (remainBits == 1)) throw `error::invalid_message`; // we check that there is no excess in the slice
    }
    // else forward_payload in slice - arbitrary bits and refs
}

@inline
fun cell?.setTokenSnakeMetadataEntry(mutate self, key: int, value: slice) {
    self.uDictSetRef(256, key, beginCell().storeUint(0, 8).storeSlice(value).endCell());
    return self;
}

@inline
fun createTokenOnchainMetadata(content: cell?) {
    return beginCell().storeUint(0, 8).storeDict(content).endCell();
}
