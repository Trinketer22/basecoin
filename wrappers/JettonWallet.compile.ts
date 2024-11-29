import { CompilerConfig } from '@ton/blueprint';
import { TactCompilerConfig } from '@ton/blueprint/dist/compile/CompilerConfig';

export const compile: CompilerConfig= {
    lang: 'tolk',
    entrypoint: 'contracts/jetton-wallet.tolk',
};
