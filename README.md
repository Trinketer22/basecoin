# Base Jetton

Sources originaly taken from [FunC version](https://github.com/EmelyanenkoK/basecoin)
Converted to [TOLK language](https://docs.ton.org/v3/documentation/smart-contracts/tolk/overview)

## Install Dependencies

`npm install`

## Compile Contracts

`npm run build`

## Run Tests

`npm run test`

### Deploy or run another script

`npx blueprint run` or `yarn blueprint run`

use Toncenter API:

`npx blueprint run --custom https://testnet.toncenter.com/api/v2/ --custom-version v2 --custom-type testnet --custom-key <API_KEY> `

API_KEY can be obtained on https://toncenter.com or https://testnet.toncenter.com
