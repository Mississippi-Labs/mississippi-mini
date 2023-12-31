import { SetupNetworkResult } from "./setupNetwork";
import { Account } from "starknet";
import {
    getEntityIdFromKeys,
    getEvents,
    setComponentsFromEvents,
} from "@dojoengine/utils";

export function createSystemCalls(
    { execute }: SetupNetworkResult
) {
    const initRole = async (signer: Account) => {
        try {
            await execute(
                signer,
                "mississippi_mini::config::config",
                "init_role",
                []
            );
        } catch (e) {
            console.log(e);
        }
    };

    const initSkill = async (signer: Account) => {
        try {
            let {transaction_hash} = await execute(
                signer,
                "mississippi_mini::config::config",
                "init_skill",
                []
            );
        } catch (e) {
            console.log(e);
        }
    };

    

    const chooseRole = async (signer: Account, role: any) => {
        try {
            await execute(
                signer,
                "mississippi_mini::game::game",
                "choose_role",
                [role]
            );
        } catch (e) {
            console.log(e);
        }
    };

    const chooseSkill = async (signer: Account, skill: any) => {
        try {
            await execute(
                signer,
                "mississippi_mini::game::game",
                "choose_skill",
                [skill]
            );
        } catch (e) {
            console.log(e);
        }
    }

    const startBattle = async (signer: Account, target: any) => {
        try {
            let {transaction_hash} = await execute(
                signer,
                "mississippi_mini::game::game",
                "start_battle",
                [target]
            );
            // return transaction_hash;
            let event = getEvents(
                await signer.waitForTransaction(transaction_hash, {
                    retryInterval: 300,
                })
            )
            return event
        } catch (e) {
            console.log(e);
        }
    }

    return {
        chooseRole,
        initRole,
        initSkill,
        startBattle,
        chooseSkill
    };
}
