import {Controller, Get, Param} from "@nestjs/common";
import {ethers, Wallet} from "ethers";
import {ConfigService} from "@nestjs/config";

// eslint-disable-next-line @typescript-eslint/no-var-requires
const wl = require('./../resources/whitelist.json');

@Controller("rockers")
export class AppController {

    private readonly whiteList: Set<string>;
    private readonly signingWallet: Wallet;

    constructor(private configService: ConfigService) {
        let signingKey: string = this.configService.get<string>('SIGNER_KEY');
        if (!signingKey) {
            throw new Error("Missing property SIGNER_KEY");
        }
        signingKey = signingKey.startsWith("0x") ? signingKey : "0x" + signingKey;
        this.whiteList = new Set(wl.whitelist);
        this.signingWallet = new ethers.Wallet(signingKey);
    }

    @Get("get-signature/:address")
    public async getHexProof(@Param("address") address: string): Promise<Sig> {
        if (this.whiteList.has(address)) {
            let message = ethers.utils.solidityPack(["address"], [address]);
            message = ethers.utils.solidityKeccak256(["bytes"], [message]);
            const signature = await this.signingWallet.signMessage(ethers.utils.arrayify(message));
            return {
                signature: signature
            }
        } else {
            console.log(`address ${address} is not whitelisted`);
            return {
                signature: ''
            }
        }
    }
}

type Sig = {
    signature: string
}
