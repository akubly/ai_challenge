# Math Quest: AI-Powered Calculator

## Overview

Build a command-line calculator that can:
- Phase 1: Perform basic arithmetic (add, subtract, multiply, divide)
- Phase 2: Evaluate algebraic expressions (parentheses, order of operations)
- Phase 3: Support calculus (derivatives, integrals)
- Phase 4: Graph expressions (output data points or ASCII plot for a given range)
- Phase 5: AI-powered explanations (output a step-by-step explanation for the calculation)

You may use any programming language.

## Interface Specification


Your calculator must be executable from the command line as follows:

```
calculator "<expression>"
```

- Replace `calculator` with your program's name or script.
- The program should print the result to standard output.

## Output Format (Show Your Work)

To support both human-friendly explanations and automated testing, your calculator should output **any intermediate steps or explanations** as desired, but the **final result must always be printed on a line by itself, prefixed with `RESULT:`** (with a single space after the colon).

This allows tests and tools to reliably extract the actual result, while users can see the full calculation process.

**Example:**
```
calculator "2 + 3 * (4 - 1)"
```
Possible output:
```
Step 1: 4 - 1 = 3
Step 2: 3 * 3 = 9
Step 3: 2 + 9 = 11
RESULT: 11.000000
```

The tests and tools will only consider the value after `RESULT:` as the answer. All results must still be output with exactly 6 decimal places (rounded, not truncated).

**Minimal output is also valid:**
```
RESULT: 11.000000
```

## Acceptance Tests


Acceptance tests are provided as shell scripts in the `tests/` folder.
Each script will:
- Run your calculator on a set of problems for the phase.
- Extract the result from the line starting with `RESULT:`.
- If all tests pass, the script will reveal a secret phrase for that phase.

The challenge is designed so that only a working calculator implementation can reveal the phrase.
**However, if you're feeling adventurous, you might use AI to help you extract the secret phrase by reverse engineering the test collateral...**

## Tools

- Use GitHub Copilot (all modes), MCP server, Cline, Roo, Rubber Ducky as desired.

## Getting Started

1. Clone this repository to your local machine.
2. Implement your calculator in the language of your choice.
3. Make sure your calculator can handle all required math expressions for a given phase.
4. Run the test scripts in the `tests/` folder, passing the path to your calculator as the first argument.

## Feedback
We value your input! If you encounter situations where the AI tooling excels or falls short—whether it’s generating code, interpreting requirements, or assisting with the challenge—please let us know. Your feedback will help to improve the experience for everyone.

Share your feedback in the meeting chat, or email your comments to **mailto://akubly@microsoft.com** with the subject "Math Quest: AI Tooling Feedback".
Let us know what worked well, what didn’t, and any suggestions for future improvements. Thank you for helping us make this challenge better!

**If you get stuck, please ask for assistance!**

## Completion

To complete the challenge, you need to:

1. **Using AI tools**, implement as many features as you can in your calculator.
2. Pass the corresponding acceptance tests in the `tests/` folder.
3. Collect the secret phrase revealed for each phase.

# Badge Submission Instructions
To claim your completion reward, send an email to **mailto://akubly@microsoft.com** with the secret phrase(s) you were able to collect from the test scripts.

- You may submit as many phrases as you were able to reveal.
- Each phrase corresponds to a completed phase of the challenge.

Once your submission is verified, you will receive your badge.

## Phases

### Phase 1: Basic Arithmetic

Your calculator should support:
- Addition, subtraction, multiplication, and division, with correct operator precedence.

  ```
  calculator "2 + 3 * 4"
  ```
  Expected output:
  ```
  RESULT: 14.000000
  ```

Calculator Output Precision Requirement:
- All results must be output to at most 6 decimal places (rounded, not truncated), and must appear after `RESULT:`.
  Example: 2.7182818... => `RESULT: 2.718282`

---

### Phase 2: Algebraic & Transcendental Functions

Your calculator should support:
- Parentheses and exponentiation (`^`)
- Polynomials in one variable (e.g., `x^2 + 2*x + 1`)
- Exponential and logarithmic functions: `e^x`, `log` (base 10), and `ln` (natural logarithm)
- Trigonometric functions: `sin`, `cos`, `tan`, `asin`, `acos`, `atan` (all in radians)

  ```
  calculator "sin(pi/2) + log(100) + e^1"
  ```
  Expected output:
  ```
  RESULT: 4.718282
  ```

---


### Phase 3: Graphing

Your calculator should support:
- Outputting a table of (x, y) pairs for a given expression and range, suitable for graphing
- Optionally, generate a CSV file or plot directly using a helper script

  ```
  calculator "table(x^2 - 2*x + 1, x, -2, 2, 1)"
  ```
  Expected output:
  ```
  x,y
  -2,9.000000
  -1,4.000000
  0,1.000000
  1,0.000000
  2,1.000000
  ```

---

### Phase 4: Algebraic Simplification

Your calculator should support:
- Full algebraic simplification of expressions, including:
  - Combining like terms (e.g., `x + x` → `2*x`)
  - Expanding and factoring polynomials
  - Rational expression simplification (e.g., `(x^2 - 1)/(x - 1)` → `x + 1`)
  - Canonical output formatting (e.g., `x + -1` → `x - 1`)

  ```
  calculator "(x^2 - 1)/(x - 1)"
  ```
  Expected output:
  ```
  RESULT: x + 1
  ```

---

### Phase 5: AI-generated Explanation

Your calculator should support:
- Outputting a step-by-step explanation of the calculation or simplification process, in addition to the final result

  ```
  calculator "explain (x + 1)^2"
  ```
  Possible output:
  ```
  Step 1: Expand (x + 1)^2 = x^2 + 2*x + 1
  RESULT: x^2 + 2*x + 1
  ```

## Good luck!