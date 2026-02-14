### [S-#] TITLE (Root Cause + Impact)

**Description:** 

**Impact:** 

**Proof of Concept:**

**Recommended Mitigation:**                                                                                [H-XX] Missing initializer calls for UUPSUpgradeable and ReentrancyGuardTransientUpgradeable break upgrade safety and reentrancy protection
Submitted by <your-handle>
Impact

The pFT contract inherits from both UUPSUpgradeable and ReentrancyGuardTransientUpgradeable, but fails to invoke their respective initializer functions during contract initialization.

This results in both modules being left in an uninitialized state, which can lead to:

Broken or unsafe upgrade authorization logic in the UUPS proxy pattern

Incorrect or non-functional reentrancy protection

Undefined behavior in future upgrades

Potential upgrade bricking or upgrade authorization bypass

False sense of security around reentrancy protection

This flaw undermines the safety guarantees of the upgradeable architecture and exposes the protocol to upgrade-related failures and potential security risks.

Root Cause

In upgradeable contracts using OpenZeppelin’s initializer pattern, all inherited upgradeable modules must be explicitly initialized inside the initialize() function.

However, in pFT.initialize(), only the ERC721 modules are initialized:

function initialize(address _putManager) public initializer {
    __ERC721_init("Flying Tulip PUT", "ftPUT");
    __ERC721Enumerable_init();
    _setPutManager(_putManager);
}


The following parent initializers are missing:

__UUPSUpgradeable_init()

__ReentrancyGuardTransient_init()

This leaves both modules in an uninitialized state.

Affected Code

Found in pFT.sol:

contract pFT is
    Initializable,
    IftPut,
    ERC721EnumerableUpgradeable,
    ReentrancyGuardTransientUpgradeable,
    UUPSUpgradeable
{
    function initialize(address _putManager) public initializer {
        __ERC721_init("Flying Tulip PUT", "ftPUT");
        __ERC721Enumerable_init();
        _setPutManager(_putManager);
        //@audit - high why no __UUPSUpgradeable_init() and  __ReentrancyGuardTransient_init();
    }
}

Security Implications
UUPSUpgradeable not initialized

May break internal upgrade safety mechanisms

Can cause upgrade authorization logic to malfunction

Risks upgrade bricking or unintended upgrade paths

ReentrancyGuardTransientUpgradeable not initialized

Reentrancy guard may silently fail

Critical functions protected with nonReentrant may not be properly secured

Creates a false sense of protection against reentrancy attacks

Recommended Mitigation Steps

Add the missing initializer calls to the initialize() function:

function initialize(address _putManager) public initializer {
    __ERC721_init("Flying Tulip PUT", "ftPUT");
    __ERC721Enumerable_init();
    __UUPSUpgradeable_init();
    __ReentrancyGuardTransient_init();
    _setPutManager(_putManager);
}


This ensures that all inherited upgradeable modules are properly initialized and their internal state is correctly configured.