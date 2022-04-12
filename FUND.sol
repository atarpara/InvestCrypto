// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.7;

import {IAAVE} form "./IAAVE.sol";
import {IVault} from "./IVAULT.sol";
import {TransferHelper} from "./TransferHelper.sol";

contract FUND {

   address public constant VAULT = address(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
   address public constant AAVE =  address(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);
    

    event _deposit(address asset,uint256 amount,address onBehalfOf,uint16 referralCode);
    event _withdraw(address asset, uint256 amount, address to);

    struct _singleSwap {
        IVault.SingleSwap _single;
        IVault.FundManagement _fund;
        uint256 _limit;
        uint256 _deadline;
    }

    struct Withdraw{
        address _atoken;
        address _token;
        uint256 _amount;
        address _to;
    }


    function deposit(_singleSwap[] memory _singleswap,address _user) public  {
        for (uint i=0; i < _singleswap.length ; i++ ){
            TransferHelper.safeTransferFrom(_singleswap[i]._single.assetIn, msg.sender, address(this), _singleswap[i]._single.amount);
            TransferHelper.safeApprove(_singleswap[i]._single.assetIn, VAULT, _singleswap[i]._single.amount);
            
            uint256 amountCalculated = IVault(VAULT).swap(_singleswap[i]._single, _singleswap[i]._fund, _singleswap[i]._limit, _singleswap[i]._deadline);
            TransferHelper.safeApprove(_singleswap[i]._single.assetOut, AAVE, amountCalculated)  ;       //approval 
            
            IAAVE(AAVE).deposit(_singleswap[i]._single.assetOut,amountCalculated,_user,0);
            emit _deposit(_singleswap[i]._single.assetOut,amountCalculated,_user,0);

        }
    }
    function withdraw(Withdraw[] memory _with) public {
        for (uint i =0 ; i < _with.length ; i++){
            TransferHelper.safeTransferFrom(_with[i]._atoken , msg.sender, address(this) , _with[i]._amount);
            // TransferHelper.safeApprove(_with[i]._token, AAVE, _with[i]._amount);
            IAAVE(AAVE).withdraw(_with[i]._token, _with[i]._amount, _with[i]._to);
            emit _withdraw(_with[i]._token, _with[i]._amount, _with[i]._to);
        }     
    }
}