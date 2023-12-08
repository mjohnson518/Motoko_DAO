import DAO "main"; 
import Debug "mo:base/Debug";

// Instantiate actor
let dao = DAO.DAO();

// simple test 
public func testAddMember() {
  let testMember = {
    name = "Alice",
    age = 30
  };
  
  // Call the addMember function and check the result
  let result = await dao.addMember(testMember);
  assert(result == #ok(()), "Failed to add member");
}

// test function for an error case
public func testAddExistingMember() {
  let testMember = {
    name = "Bob",
    age = 25
  };
  
  // Assuming Bob is already a member
  let result = await dao.addMember(testMember);
  assert(result == #err("Already a member"), "Should fail when adding an existing member");
}


// Run tests
public func runTests() {
  testAddMember();
  testAddExistingMember();
  // Call other test functions here...
}

// Assert function for testing
private func assert(condition: Bool, message: Text) {
  if (!condition) {
    Debug.print("Test failed: " + message);
  } else {
    Debug.print("Test passed: " + message);
  }
}