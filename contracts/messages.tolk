const MSG_INFO_REST_BITS = 1 + 4 + 4 + 64 + 32;

const MSG_WITH_STATE_INIT_AND_BODY_SIZE = `MSG_INFO_REST_BITS` + 1 + 1 + 1;
const MSG_HAVE_STATE_INIT = 4;
const MSG_STATE_INIT_IN_REF = 2;
const MSG_BODY_IN_REF = 1;
const MSG_ONLY_BODY_SIZE = MSG_INFO_REST_BITS + 1 + 1;

// Creates an output action which would reserve exactly x nanograms (if y = 0).
const RESERVE_REGULAR = 0;
// Creates an output action which would reserve at most x nanograms (if y = 2).
// Bit +2 in y means that the external action does not fail if the specified amount cannot be reserved; instead, all remaining balance is reserved.
const RESERVE_AT_MOST = 2;
// in the case of action fail - bounce transaction. No effect if RESERVE_AT_MOST (+2) is used. TVM UPGRADE 2023-07. https://docs.ton.org/learn/tvm-instructions/tvm-upgrade-2023-07#sending-messages
const RESERVE_BOUNCE_ON_ACTION_FAIL = 16;

@inline
fun loadOp(mutate self: slice) {
    return self.loadUint(32);
}

@inline
fun storeOp(mutate self: builder, op: int) {
    return self.storeUint(op, 32);
}

@inline
fun loadQueryId(mutate self: slice) {
    return self.loadUint(64);
}

@inline
fun storeQueryId(mutate self: builder, queryId: int) {
    return self.storeUint(queryId, 64);
}

@inline
fun skipQueryId(mutate self: slice) {
    return self.skipBits(64);
}

@inline
fun loadOpAndQueryId(mutate self: slice) {
    return (self.loadOp(), self.loadQueryId());
}

@inline
fun storeMsgFlagsAndAddressNone(mutate self: builder, msgFlags: int) {
    return self.storeUint(msgFlags, 6);
}

@inline
fun loadMsgFlags(mutate self: slice) {
    return self.loadUint(4);
}

@inline
fun retrieveFwdFee(inMsgFull: slice) {

    inMsgFull.loadAddress();
    inMsgFull.loadCoins();
    inMsgFull.skipDict();
    inMsgFull.loadCoins();
    return inMsgFull.loadCoins();
}

@inline
fun storeStateinitRefAndBodyRef(b: builder, stateInit: cell, body: cell) {
    return b.storeUint(MSG_HAVE_STATE_INIT + MSG_STATE_INIT_IN_REF + MSG_BODY_IN_REF, MSG_WITH_STATE_INIT_AND_BODY_SIZE)
            .storeRef(stateInit)
            .storeRef(body);
}

@inline
fun storeOnlyBodyRef(b: builder, body: cell) {
    return b
    .storeUint(MSG_BODY_IN_REF, MSG_ONLY_BODY_SIZE)
    .storeRef(body);
}

@inline
fun storePrefixOnlyBody(b: builder) {
    return b.storeUint(0, MSG_ONLY_BODY_SIZE);
}

@inline
fun isAddressNone(s: slice) {
    return s.preloadUint(2) == 0;
}
