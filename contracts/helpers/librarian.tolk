// Simple library keeper

import "@stdlib/gas-payments"
import "../messages.tolk"


const DEFAULT_DURATION = 3600 * 24 * 365 * 100; // 100 years, can top-up in any time
const ONE_TON = 1000000000;

@pure
fun empty(): cell
    asm "<b b> PUSHREF";

// https://docs.ton.org/tvm.pdf, page 138, SETLIBCODE
fun setLibCode(code: cell, mode: int): void
    asm "SETLIBCODE";

fun onInternalMessage(msgValue: int, inMsgFull: cell, inMsgBody: slice) {
    var cs: slice = inMsgFull.beginParse();
    var flags: int = cs.loadUint(4);
    var sender: slice = cs.loadAddress();


    var libToPublish: cell = getContractData();

    var initialGas: int = getGasConsumedAtTheMoment();
    var (orderCells: int, orderBits: int, _) = calculateCellSizeStrict(libToPublish, 2048);
    var sizeCountingGas: int = getGasConsumedAtTheMoment() - initialGas;

    var toReserve: int = calculateGasFeeWithoutFlatPrice(MASTERCHAIN, sizeCountingGas) +
                     calculateStorageFee(MASTERCHAIN, DEFAULT_DURATION, orderBits, orderCells);
    reserveToncoinsOnBalance(toReserve, RESERVE_BOUNCE_ON_ACTION_FAIL);
    var msg: cell = beginCell()
            .storeMsgFlagsAndAddressNone(NON_BOUNCEABLE)
            .storeSlice(sender)
            .storeCoins(0)
            .storePrefixOnlyBody()
            .endCell();
    sendRawMessage(msg, SEND_MODE_CARRY_ALL_BALANCE);
    // https://docs.ton.org/tvm.pdf, page 138, SETLIBCODE
    setLibCode(libToPublish, 2);  // if x = 2, the library is added as a public library (and becomes available to all smart contracts if the current smart contract resides in the masterchain);
    // brick contract
    setContractCodePostponed(empty());
    setContractData(empty());
}
