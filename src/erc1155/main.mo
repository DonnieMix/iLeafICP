import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";
import Error "mo:base/Error";
import Iter "mo:base/Iter";

actor class ILeafERC1155(owner: Principal, erc20: Principal) = this {
    let contractOwner = owner;

    var balances = HashMap.HashMap<(Principal, Nat), Nat>(10, func(x, y) { x == y }, func(x) { Nat32.fromNat(x.1) ^ Principal.hash(x.0) });
    var userNextTreeID = HashMap.HashMap<Principal, Nat>(10, Principal.equal, Principal.hash);
    var userTreeIDs = HashMap.HashMap<Principal, [Nat]>(10, Principal.equal, Principal.hash);
    var userTreeNextBurnID = HashMap.HashMap<(Principal, Nat), Nat>(10, func(x, y) { x == y }, func(x) { Nat32.fromNat(x.1) ^ Principal.hash(x.0) });
    var userTreeSize = HashMap.HashMap<(Principal, Nat), Nat>(10, func(x, y) { x == y }, func(x) { Nat32.fromNat(x.1) ^ Principal.hash(x.0) });
    var userTreeLeafPrice = HashMap.HashMap<(Principal, Nat), Nat>(10, func(x, y) { x == y }, func(x) { Nat32.fromNat(x.1) ^ Principal.hash(x.0) });
    
    let erc20Canister: actor {
        mint: shared (recipient: Principal, amount: Nat) -> async ();
    } = actor (Principal.toText(erc20));

    public query func leafBalance(user: Principal, treeID: Nat) : async Nat {
        return Option.get(userTreeSize.get((user, treeID)), 0) - Option.get(userTreeNextBurnID.get((user, treeID)), 0);
    };

    public query func balanceOf(user: Principal, leafId: Nat) : async Nat {
        return Option.get(balances.get((user, leafId)), 0);
    };
    
    public shared (msg) func mintTree(to: Principal, leafAmount: Nat, leafPrice: Nat) : async () {
        if (msg.caller != contractOwner) throw Error.reject("Only owner can mint trees");
        if (leafAmount == 0) throw Error.reject("Tree cannot be empty");
        
        let treeID = Option.get(userNextTreeID.get(to), 0);
        userNextTreeID.put(to, treeID + 1);
        
        let currentTrees = Option.get(userTreeIDs.get(to), []);
        userTreeIDs.put(to, Array.append<Nat>(currentTrees, [treeID]));

        for (i in Iter.range(0, leafAmount - 1)) {
            let leafId = Nat32.toNat((Principal.hash(to) << 96)) + Nat32.toNat((Nat32.fromNat(treeID) << 48)) + i;
            balances.put((to, leafId), 1);
        };
        
        userTreeSize.put((to, treeID), leafAmount);
        userTreeLeafPrice.put((to, treeID), leafPrice);
        userTreeNextBurnID.put((to, treeID), 0);
    };
    
    public shared (msg) func burnLeaf(from: Principal, treeID: Nat) : async () {
        if (msg.caller != contractOwner) throw Error.reject("Only owner can burn leaves");
        let burnID = Option.get(userTreeNextBurnID.get((from, treeID)), 0);
        let treeSize = Option.get(userTreeSize.get((from, treeID)), 0);
        let leafPrice = Option.get(userTreeLeafPrice.get((from, treeID)), 0);
        
        if (burnID >= treeSize) throw Error.reject("The tree has no leaves left");
        let leafId = Nat32.toNat((Principal.hash(from) << 96)) + Nat32.toNat((Nat32.fromNat(treeID) << 48)) + burnID;
        balances.delete((from, leafId));
        userTreeNextBurnID.put((from, treeID), burnID + 1);
        ignore erc20Canister.mint(from, leafPrice);
        
        if (burnID + 1 >= treeSize) {
            userTreeSize.delete((from, treeID));
            userTreeLeafPrice.delete((from, treeID));
            userTreeNextBurnID.delete((from, treeID));
        }
    };
}
