import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Account "account";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Http "http";


actor class DAO()  {

    // L1 

    let name : Text = "Carbon Twelve DAO";
    var manifesto : Text = "Carbon Twelve (C12) aims to harness the power of the Internet Computer to forge a more sustainable future.";

    let goals : Buffer.Buffer<Text> = Buffer.Buffer<Text>(0);

    public shared query func getName() : async Text {
        return name;
    };

    public shared query func getManifesto() : async Text {
        return manifesto;
    };

    public func setManifesto(newManifesto : Text) : async () {
        manifesto := newManifesto;
        return;
    };

    public func addGoal(newGoal : Text) : async () {
        goals.add(newGoal);
        return;
    };

    public shared query func getGoals() : async [Text] {
        return Buffer.toArray(goals);
    };

   
    // L2

    public type Member = {
        name : Text;
        age : Nat;
    };
    public type Result<A, B> = Result.Result<A, B>;
    public type HashMap<A, B> = HashMap.HashMap<A, B>;

    let dao : HashMap<Principal, Member> = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);

    public shared ({ caller }) func addMember(member : Member) : async Result<(), Text> {
        switch (dao.get(caller)) {
            case (?member) {
                return #err("Already a member");
            };
            case (null) {
                dao.put(caller, member);
                return #ok(());
            };
        };
    };

    public shared ({ caller }) func updateMember(member : Member) : async Result<(), Text> {
        switch (dao.get(caller)) {
            case (?member) {
                dao.put(caller, member);
                return #ok(());
            };
            case (null) {
                return #err("Not a member");
            };
        };
    };

    public shared ({ caller }) func removeMember() : async Result<(), Text> {
        switch (dao.get(caller)) {
            case (?member) {
                dao.delete(caller);
                return #ok(());
            };
            case (null) {
                return #err("Not a member");
            };
        };
    };

    public query func getMember(p : Principal) : async Result<Member, Text> {
        switch (dao.get(p)) {
            case (?member) {
                return #ok(member);
            };
            case (null) {
                return #err("Not a member");
            };
        };
    };

    public query func getAllMembers() : async [Member] {
        return Iter.toArray(dao.vals());
    };

    public query func numberOfMembers() : async Nat {
        return dao.size();
    };

    // L3

    public type Subaccount = Blob;
    public type Account = {
        owner : Principal;
        subaccount : ?Subaccount;
    };

    let nameToken = "C12 Token";
    let symbolToken = "C12T";

    let ledger : TrieMap.TrieMap<Account, Nat> = TrieMap.TrieMap(Account.accountsEqual, Account.accountsHash);

    public query func tokenName() : async Text {
        return nameToken;
    };

    public query func tokenSymbol() : async Text {
        return symbolToken;
    };

    public func mint(owner : Principal, amount : Nat) : async () {
        let defaultAccount = { owner = owner; subaccount = null };
        switch (ledger.get(defaultAccount)) {
            case (null) {
                ledger.put(defaultAccount, amount);
            };
            case (?some) {
                ledger.put(defaultAccount, some + amount);
            };
        };
        return;
    };

    public shared ({ caller }) func transfer(from : Account, to : Account, amount : Nat) : async Result<(), Text> {
        let fromBalance = switch (ledger.get(from)) {
            case (null) { 0 };
            case (?some) { some };
        };
        if (fromBalance < amount) {
            return #err("Not enough balance");
        };
        let toBalance = switch (ledger.get(to)) {
            case (null) { 0 };
            case (?some) { some };
        };
        ledger.put(from, fromBalance - amount);
        ledger.put(to, toBalance + amount);
        return #ok();
    };

    public query func balanceOf(account : Account) : async Nat {
        return switch (ledger.get(account)) {
            case (null) { 0 };
            case (?some) { some };
        };
    };

    public query func totalSupply() : async Nat {
        var total = 0;
        for (balance in ledger.vals()) {
            total += balance;
        };
        return total;
    };

    // L4

     public type Status = {
        #Open;
        #Accepted;
        #Rejected;
    };

    public type Proposal = {
        id : Nat;
        status : Status;
        manifest : Text;
        votes : Int;
        voters : [Principal];
    };

    public type CreateProposalOk = Nat;

    public type CreateProposalErr = {
        #NotDAOMember;
        #NotEnoughTokens;
        #NotImplemented; 
    };

    public type createProposalResult = Result<CreateProposalOk, CreateProposalErr>;

    public type VoteOk = {
        #ProposalAccepted;
        #ProposalRefused;
        #ProposalOpen;
    };

    public type VoteErr = {
        #ProposalNotFound;
        #AlreadyVoted;
        #ProposalEnded;
        #NotImplemented; 
    };

    public type voteResult = Result<VoteOk, VoteErr>;

    public shared ({ caller }) func createProposal(manifest : Text) : async createProposalResult {
        return #err(#NotImplemented);
    };

    public query func getProposal(id : Nat) : async ?Proposal {
        return null;
    };

    public shared ({ caller }) func vote(id : Nat, vote : Bool) : async voteResult {
        return #err(#NotImplemented);
    };

    //L5

    public type DAOStats = {
        name : Text;
        manifesto : Text;
        goals : [Text];
        member : [Text];
        logo : Text;
        numberOfMembers : Nat;
    };
    public type HttpRequest = Http.Request;
    public type HttpResponse = Http.Response;

    public func http_request(request : HttpRequest) : async HttpResponse {
        return ({
            status_code = 404;
            headers = [];
            body = Blob.fromArray([]);
            streaming_strategy = null;
        });
    };

    public query func getStats() : async DAOStats {
        return ({
            name = "";
            manifesto = "";
            goals = [];
            member = [];
            logo = "";
            numberOfMembers = 0;
        });
    };

    //L6 

    public type Socials = {
        Twitter: ?Text;
        GitHub: ?Text;
        Linkedin: ?Text;
        Instagram: ?Text;
        TikTok: ?Text;
        OpenChat: ?Text;
    };

    public type Images = {
        urlLogo: ?Text;
        urlBanner: ?Text;
    };

    // L6 Data
    let socialsAuthor: Socials = {
        Twitter = ?"https://twitter.com/marcjohnson518";
        GitHub = ?"https://github.com/mjohnson518";
        Linkedin = null;
        Instagram = null;
        TikTok = null;
        OpenChat = null;
    };

    let socialsProject: Socials = {
        Twitter = ?"https://twitter.com/marcjohnson518";
        GitHub = ?"https://github.com/mjohnson518";
        Linkedin = null;
        Instagram = null;
        TikTok = null;
        OpenChat = null;
    };

    let images: Images = {
        urlLogo = ?"https://twitter.com/marcjohnson518/nft";
        urlBanner = ?"https://s3.eu-south-1.amazonaws.com/neosperience.com-media/wp-content/uploads/2022/09/30171705/nasa-Q1p7bh3SHj8-unsplash-640x426.jpg";
    };

    // Level 6 Functions
    public query func getName_MBC() : async Text {
        return name;
    };

    public query func getDescription_MBC() : async Text {
        return manifesto;
    };

    public query func getAuthor_MBC() : async Text {
        return "Author Name";
    };

    public query func getSocialsAuthor_MBC() : async Socials {
        return socialsAuthor;
    };

    public query func getSocialsProject_MBC() : async Socials {
        return socialsProject;
    };

    public query func getImages_MBC() : async Images {
        return images;
    }
};