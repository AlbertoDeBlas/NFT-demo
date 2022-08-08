from scripts.helpful_scripts import (
    get_account,
    OPENSEA_URL,
    get_contract,
    fund_with_link,
)
from brownie import AdvancedCollectible, network, config, Contract
import time

sample_token_uri = (
    "ipfs://Qmd9MCGtdVz2miNumBHDbvj8bigSgTwnr4SbyH6DNnpWdt?filename=0-PUG.json"
)


def deploy():
    account = get_account()
    advanced_collectible = AdvancedCollectible.deploy(
        get_contract("vrf_coordinator"),
        get_contract("link_token"),
        config["networks"][network.show_active()]["keyhash"],
        config["networks"][network.show_active()]["fee"],
        {"from": account},
    )
    return advanced_collectible


def create():
    account = get_account()

    # TODO parameterize this
    advanced_collectible = Contract("0x3F9DA6752BD629BBD31F69A776C1983E2C9CAEC7")

    # subscription = fund_with_link(advanced_collectible.address)
    print("New contract has been created")
    creating_tx = advanced_collectible.createCollectible({"from": account})
    creating_tx.wait(1)
    time.sleep(60)
    print("New token has been created")
    print(f"You have created {advanced_collectible.tokenCounter()} collectibles!")
    return advanced_collectible, creating_tx


def main(option):
    if option == 1:
        deploy()
    else:
        create()
