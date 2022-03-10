/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import { Provider, TransactionRequest } from "@ethersproject/providers";
import type {
  PRBProxyFactory,
  PRBProxyFactoryInterface,
} from "../PRBProxyFactory";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "origin",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "deployer",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        indexed: false,
        internalType: "bytes32",
        name: "seed",
        type: "bytes32",
      },
      {
        indexed: false,
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
      {
        indexed: false,
        internalType: "address",
        name: "proxy",
        type: "address",
      },
    ],
    name: "DeployProxy",
    type: "event",
  },
  {
    inputs: [],
    name: "deploy",
    outputs: [
      {
        internalType: "address payable",
        name: "proxy",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
    ],
    name: "deployFor",
    outputs: [
      {
        internalType: "address payable",
        name: "proxy",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "eoa",
        type: "address",
      },
    ],
    name: "getNextSeed",
    outputs: [
      {
        internalType: "bytes32",
        name: "nextSeed",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "proxy",
        type: "address",
      },
    ],
    name: "isProxy",
    outputs: [
      {
        internalType: "bool",
        name: "result",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "version",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];

const _bytecode =
  "0x608060405234801561001057600080fd5b50610b1e806100206000396000f3fe608060405234801561001057600080fd5b50600436106100675760003560e01c806354fd4d501161005057806354fd4d50146100e457806374912cd2146100ec578063775c300c1461011757600080fd5b8063297103881461006c57806337a6be16146100ad575b600080fd5b61009861007a3660046102a6565b6001600160a01b031660009081526020819052604090205460ff1690565b60405190151581526020015b60405180910390f35b6100d66100bb3660046102a6565b6001600160a01b031660009081526001602052604090205490565b6040519081526020016100a4565b6100d6600181565b6100ff6100fa3660046102a6565b61011f565b6040516001600160a01b0390911681526020016100a4565b6100ff610289565b32600081815260016020908152604080832054815192830194909452810183905290919082906060016040516020818303038152906040528051906020012090508060405161016d90610299565b8190604051809103906000f590508015801561018d573d6000803e3d6000fd5b506040517ff2fde38b0000000000000000000000000000000000000000000000000000000081526001600160a01b0386811660048301529194509084169063f2fde38b90602401600060405180830381600087803b1580156101ee57600080fd5b505af1158015610202573d6000803e3d6000fd5b505050506001600160a01b03838116600081815260208181526040808320805460ff191660019081179091553280855281845293829020908801905580518781529182018690528101929092529186169133917f6aafca263a35a9d2a6e4e4659a84688092f4ae153df2f95cd7659508d95c18709060600160405180910390a45050919050565b60006102943361011f565b905090565b61083b806102d783390190565b6000602082840312156102b857600080fd5b81356001600160a01b03811681146102cf57600080fd5b939250505056fe608060405234801561001057600080fd5b50611388600155600080546001600160a01b0319163390811782556040519091907f5c486528ec3e3f0ea91181cff8116f02bfa350e03b8b6f12e00765adbb5af85c908290a36107d6806100656000396000f3fe6080604052600436106100695760003560e01c8063da8d882c11610043578063da8d882c146100fa578063e64624fa14610166578063f2fde38b1461018857600080fd5b80631cff79cd146100755780638da5cb5b1461009e5780639d159568146100d657600080fd5b3661007057005b600080fd5b610088610083366004610578565b6101a8565b6040516100959190610648565b60405180910390f35b3480156100aa57600080fd5b506000546100be906001600160a01b031681565b6040516001600160a01b039091168152602001610095565b3480156100e257600080fd5b506100ec60015481565b604051908152602001610095565b34801561010657600080fd5b5061015661011536600461067a565b6001600160a01b0392831660009081526002602090815260408083209490951682529283528381206001600160e01b03199290921681529152205460ff1690565b6040519015158152602001610095565b34801561017257600080fd5b506101866101813660046106bd565b610428565b005b34801561019457600080fd5b506101866101a3366004610718565b6104b8565b6000546060906001600160a01b03163314610262573360009081526002602090815260408083206001600160a01b0388168452825280832086356001600160e01b03198116855292529091205460ff16610260576000546040517fa2ee03b80000000000000000000000000000000000000000000000000000000081526001600160a01b03918216600482015233602482015290861660448201526001600160e01b0319821660648201526084015b60405180910390fd5b505b6001600160a01b0384163b6102ae576040517f29ba3bdf0000000000000000000000000000000000000000000000000000000081526001600160a01b0385166004820152602401610257565b600080546001546001600160a01b0390911691905a6102cd9190610733565b90506000866001600160a01b03168287876040516102ec929190610771565b6000604051808303818686f4925050503d8060008114610328576040519150601f19603f3d011682016040523d82523d6000602084013e61032d565b606091505b506000549095509091506001600160a01b03848116911614610392576000546040517fbcac60ce0000000000000000000000000000000000000000000000000000000081526001600160a01b0380861660048301529091166024820152604401610257565b866001600160a01b03167fb24ebe141c5f2a744b103bea65fce6c40e0dc65d7341d092c09b160f404479908787876040516103cf93929190610781565b60405180910390a28061041e578351156103ec5783518085602001fd5b6040517fe336368800000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b5050509392505050565b6000546001600160a01b031633146104685760005460405163ac976e3960e01b81526001600160a01b039091166004820152336024820152604401610257565b6001600160a01b0393841660009081526002602090815260408083209590961682529384528481206001600160e01b03199390931681529190925291909120805460ff1916911515919091179055565b6000546001600160a01b03163381146104f55760405163ac976e3960e01b81526001600160a01b0382166004820152336024820152604401610257565b600080547fffffffffffffffffffffffff0000000000000000000000000000000000000000166001600160a01b0384811691821783556040519192908416917f5c486528ec3e3f0ea91181cff8116f02bfa350e03b8b6f12e00765adbb5af85c9190a35050565b80356001600160a01b038116811461057357600080fd5b919050565b60008060006040848603121561058d57600080fd5b6105968461055c565b9250602084013567ffffffffffffffff808211156105b357600080fd5b818601915086601f8301126105c757600080fd5b8135818111156105d657600080fd5b8760208285010111156105e857600080fd5b6020830194508093505050509250925092565b6000815180845260005b8181101561062157602081850181015186830182015201610605565b81811115610633576000602083870101525b50601f01601f19169290920160200192915050565b60208152600061065b60208301846105fb565b9392505050565b80356001600160e01b03198116811461057357600080fd5b60008060006060848603121561068f57600080fd5b6106988461055c565b92506106a66020850161055c565b91506106b460408501610662565b90509250925092565b600080600080608085870312156106d357600080fd5b6106dc8561055c565b93506106ea6020860161055c565b92506106f860408601610662565b91506060850135801515811461070d57600080fd5b939692955090935050565b60006020828403121561072a57600080fd5b61065b8261055c565b60008282101561076c577f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b500390565b8183823760009101908152919050565b60408152826040820152828460608301376000606084830101526000601f19601f850116820160608382030160208401526107bf60608201856105fb565b969550505050505056fea164736f6c634300080c000aa164736f6c634300080c000a";

type PRBProxyFactoryConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: PRBProxyFactoryConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class PRBProxyFactory__factory extends ContractFactory {
  constructor(...args: PRBProxyFactoryConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
    this.contractName = "PRBProxyFactory";
  }

  deploy(
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<PRBProxyFactory> {
    return super.deploy(overrides || {}) as Promise<PRBProxyFactory>;
  }
  getDeployTransaction(
    overrides?: Overrides & { from?: string | Promise<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  attach(address: string): PRBProxyFactory {
    return super.attach(address) as PRBProxyFactory;
  }
  connect(signer: Signer): PRBProxyFactory__factory {
    return super.connect(signer) as PRBProxyFactory__factory;
  }
  static readonly contractName: "PRBProxyFactory";
  public readonly contractName: "PRBProxyFactory";
  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): PRBProxyFactoryInterface {
    return new utils.Interface(_abi) as PRBProxyFactoryInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): PRBProxyFactory {
    return new Contract(address, _abi, signerOrProvider) as PRBProxyFactory;
  }
}
