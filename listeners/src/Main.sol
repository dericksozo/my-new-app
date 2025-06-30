// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "sim-idx-sol/Simidx.sol";
import "sim-idx-generated/Generated.sol";

contract Triggers is BaseTriggers {
    function triggers() external virtual override {
        Listener listener = new Listener();
        addTrigger(ChainIdContract(1, 0x1F98431c8aD98523631AE4a59f267346ea31F984), listener.triggerOnCreatePoolFunction());
        addTrigger(ChainIdContract(130, 0x1F98400000000000000000000000000000000003), listener.triggerOnCreatePoolFunction());
        addTrigger(ChainIdContract(8453, 0x33128a8fC17869897dcE68Ed026d694621f6FDfD), listener.triggerOnCreatePoolFunction());

        // Listen for Moonbirds Approval events on Ethereum mainnet
        addTrigger(
            ChainIdContract(1, 0x23581767a106ae21c074b2276D25e5C3e136a68b),
            listener.triggerOnApprovalEvent()
        );
    }
}

/// Index calls to the UniswapV3Factory.createPool function on Ethereum
/// To hook on more function calls, specify that this listener should implement that interface and follow the compiler errors.
contract Listener is UniswapV3Factory$OnCreatePoolFunction, Moonbirds$OnApprovalEvent {
    /// Emitted events are indexed.
    /// To change the data which is indexed, modify the event or add more events.
    event PoolCreated(uint64 chainId, address caller, address pool, address token0, address token1, uint24 fee);

    /// Emitted whenever a Moonbirds NFT approval event occurs.
    event BirdApproved(uint64 chainId, address owner, address approved, uint256 tokenId, uint256 blockNumber);

    /// The handler called whenever the UniswapV3Factory.createPool function is called.
    /// Within here you write your indexing specific logic (e.g., call out to other contracts to get more information).
    /// The only requirement for handlers is that they have the correct signature, but usually you will use generated interfaces to help write them.
    function onCreatePoolFunction(
        FunctionContext memory ctx,
        UniswapV3Factory$createPoolFunctionInputs memory inputs,
        UniswapV3Factory$createPoolFunctionOutputs memory outputs
    )
        external
        override
    {
        emit PoolCreated(uint64(block.chainid), ctx.txn.call.callee, outputs.pool, inputs.tokenA, inputs.tokenB, inputs.fee);
    }

    /// Handler for Moonbirds Approval events.
    function onApprovalEvent(
        EventContext memory /* ctx */,
        Moonbirds$ApprovalEventParams memory inputs
    )
        external
        override
    {
        emit BirdApproved(uint64(block.chainid), inputs.owner, inputs.approved, inputs.tokenId, block.number);
    }
}

