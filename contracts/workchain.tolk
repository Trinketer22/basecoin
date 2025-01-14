
import "op-codes.tolk"

const MY_WORKCHAIN = BASECHAIN;

@inline
fun isSameWorkchain(addr: slice): bool {
    var (wc: int, _) = parseStandardAddress(addr);
    return wc == MY_WORKCHAIN;
}

@inline
fun checkSameWorkchain(addr: slice) {
    assert(isSameWorkchain(addr)) throw `error::wrong_workchain`;
}
