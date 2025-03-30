import Nat "mo:base/Nat";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Error "mo:base/Error";

actor class ILeafERC20(name : Text, symbol : Text, deployer : Principal) = this {
    stable var totalSupply : Nat = 0;
    let owner = deployer;

    var balances = HashMap.HashMap<Principal, Nat>(10, Principal.equal, Principal.hash);
    var permitted = HashMap.HashMap<Principal, Bool>(10, Principal.equal, Principal.hash);

    public query func getName() : async Text {
        return name;
    };

    public query func getSymbol() : async Text {
        return symbol;
    };

    public query func getTotalSupply() : async Nat {
        return totalSupply;
    };

    public query func balanceOf(account : Principal) : async Nat {
        switch (balances.get(account)) {
            case (?balance) balance;
            case null 0;
        }
    };

    public shared (msg) func mint(to : Principal, amount : Nat) : async () {
        if (msg.caller == owner or Option.get(permitted.get(msg.caller), false)) {
            let currentBalance = switch (balances.get(to)) { case (?bal) bal; case null 0; };
            balances.put(to, currentBalance + amount);
            totalSupply += amount;
        } else {
            throw Error.reject(
                "Unauthorized: caller " # Principal.toText(msg.caller) # 
                " is not the owner " # Principal.toText(owner) # 
                " and is not permitted to mint."
            );
        };
    };

    public shared (msg) func burn(from : Principal, amount : Nat) : async () {
        if (msg.caller == owner or Option.get(permitted.get(msg.caller), false)) {
            let currentBalance = switch (balances.get(from)) { case (?bal) bal; case null 0; };
            if (currentBalance >= amount) {
                balances.put(from, currentBalance - amount);
                totalSupply -= amount;
            } else {
                throw Error.reject("Insufficient balance: requested " # Nat.toText(amount) # 
                                   " but only " # Nat.toText(currentBalance) # " available.");
            };
        } else {
            throw Error.reject(
                "Unauthorized: caller " # Principal.toText(msg.caller) # 
                " is not the owner " # Principal.toText(owner) # 
                " and is not permitted to burn."
            );
        };
    };

    public shared (msg) func setPermission(user : Principal, isPermitted : Bool) : async () {
        if (msg.caller == owner) {
            permitted.put(user, isPermitted);
        } else {
            throw Error.reject(
                "Unauthorized: caller " # Principal.toText(msg.caller) # 
                " is not the owner " # Principal.toText(owner) # 
                " and cannot set permissions."
            );
        };
    };
}
