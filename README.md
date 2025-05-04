
# Magik Programming Language

## Introduction

Welcome to **Magik** — a lightweight and imaginative programming language designed to feel like spellcasting!  
With Magik, you write code not just to execute functions, but to craft **incantations** that invoke the magic of computation.

Built on top of LLVM, Magik reimagines traditional programming constructs into magical metaphors, providing a unique, minimalistic, and enchanting programming experience.

Our goal is to offer a programming language that is **intuitive**, **expressive**, and **fun**, while retaining essential functionality for modern development.

---

## Features

Magik incorporates the core features of modern programming languages — but presents them with a mystical twist:

### Variable Binding
Use the `summon` keyword to declare and assign variables:
```magik
summon x = 10;
summon y = 5.5;
````

### Output Spell

To display output on the screen, you cast a `reveal` spell:

```magik
reveal** Magic activated! **
```

### Conditionals

Magik uses the `cast when` keyword for conditional logic:

```magik
cast when myvariable > 30:
  reveal** Power surge! **
```

### Looping

Loops in Magik are represented by the `whirl` keyword, allowing you to iterate over a range:

```magik
whirl i from 0...5:
  reveal*i*
```

### Comments

Comments in Magik are written using `@`:

```magik
@ this is a comment
```

### Operations

#### Arithmetic Operators

```magik
+    // addition  
-    // subtraction  
*    // multiplication  
/    // division  
```

#### Comparison Operators

```magik
is        // ==
not       // !=
beyond    // >
beneath   // <
notless   // >=
notmore   // <=
```

#### Logical Operators

```magik
A   // logical AND  
O   // logical OR  
N   // logical NOT  
```

---

## Conclusion

**Magik** is more than just a programming language — it's an experience.
With simplicity, originality, and charm at its core, Magik provides a fresh perspective on how programming can be a **creative, magical journey**.

Join us in casting spells through code with **Magik**!

#### TO RUN THE SAMPLE CODE AND WRITE YOUR OWN CODE IN MAGIK, PLEASE FOLLOW THESE STEPS:
1- ensure the installation of flex/bison by "sudo apt-get update" 
followed by 
"sudo apt-get install flex bison llvm clang"

2- clone this repository using "git clone https://github.com/aadilsal/Magik.git"

3-"cd Magik" and type "make"

4- type "./mgk_compiler input1.mgk"

5- finally, type "make run"


