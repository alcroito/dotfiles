---
name: writing-qt-documentation
description: Use when writing or editing Qt framework documentation, API documentation, QDoc comments, or Qt module overviews - follows QUIP-25 style guide and Microsoft Writing Style Guide conventions
---

# Writing Qt Documentation

## Overview

Qt documentation follows **QUIP-25** (Qt Documentation Writing Style) and the **Microsoft Writing Style Guide**. Write in clear, direct American English using active voice and task-oriented language.

## Language Standards

### English and Style Guide

- **American English**: Use US spelling (color, not colour; synchronize, not synchronise)
- **Microsoft Writing Style Guide**: Follow Microsoft's conventions for technical writing
- **Voice**: Active voice (the function returns data), not passive (data is returned by the function)
- **Person**: Use "you" to address the reader when appropriate
- **Tense**: Present tense (the function updates, not will update)

### Grammar Rules

**Active Voice Required:**
```
✅ The function updates the widget's content.
❌ The widget's content is updated by the function.

✅ You can call this function to initialize the object.
❌ This function can be called to initialize the object.
```

**Use "you" for the Reader:**
```
✅ You can use this function to load data.
❌ One can use this function to load data.
❌ Users can use this function to load data.
```

**Present Tense:**
```
✅ The function returns true if successful.
❌ The function will return true if successful.
```

### Word Choice

**Avoid Latin Abbreviations:**

| Use | Don't Use |
|-----|-----------|
| that is | i.e. |
| for example | e.g. |
| and so on | etc. |
| through, using | via |
| advice, warning | caveat |

**Use Clear Connectors:**
- **because** (not since or as for causation)
- **through** or **using** (not via)

**Serial Comma (Oxford Comma):**
```
✅ The function accepts strings, integers, and floating-point values.
❌ The function accepts strings, integers and floating-point values.
```

## QDoc Formatting

### Common QDoc Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `\fn` | Function signature | `\fn bool QFile::open(OpenMode mode)` |
| `\a` | Parameter reference | `The \a filename parameter specifies...` |
| `\c` | Inline code/values | `Returns \c true if successful` |
| `\l` | Link to class/function | `See \l{QFile::read()}` |
| `\sa` | See also (related items) | `\sa close(), flush()` |
| `\note` | Important note | `\note This function is thread-safe.` |
| `\warning` | Warning notice | `\warning Do not call after deletion.` |

### Function Documentation Structure

```cpp
/*!
    \fn bool MyClass::doSomething(const QString &name, int value)

    Brief one-line description of what the function does.

    More detailed explanation if needed. Use \a to reference parameters.
    The \a name parameter specifies the object name. The \a value parameter
    controls the behavior.

    Explain behavior, edge cases, and important details. Use active voice
    and present tense.

    \note Important behavioral notes go here.

    \warning Critical warnings about misuse.

    Returns \c true if successful, \c false otherwise.

    \sa relatedFunction(), otherFunction()
*/
```

### Class Documentation Structure

```cpp
/*!
    \class MyClass
    \inmodule QtMyModule
    \brief Brief one-line description.

    Detailed overview of the class purpose and capabilities.

    Explain what problems it solves and how you use it. Include
    code examples if helpful.

    \sa RelatedClass
*/
```

## Formatting Conventions

### Lists

Use consistent style in lists - same tone/mode, consistent punctuation:

```
✅ Good list (parallel structure, periods):
- Updates the display content.
- Validates the input data.
- Notifies all observers.

❌ Bad list (inconsistent structure):
- Updates the display content.
- Input data validation
- All observers are notified
```

### Numbers and Capitalization

- Spell out numbers one through nine; use numerals for 10 and above
- Use sentence case for headings (not title case)
- Use title case only for proper Qt product names

### Formatting Text Elements

- **Bold** (`\b`): UI elements, emphasis
- *Italic* (`\i`): First introduction of term
- `Code` (`\c`): Code values, literals, constants

## Red Flags - STOP and Review

If you find yourself thinking any of these, stop and review the style guide:

- "This is good enough for now, time pressure"
- "Passive voice sounds more formal/professional"
- "Future tense is clearer than present tense"
- "i.e./e.g. are standard abbreviations everyone knows"
- "via is a common English word now"
- "The Oxford comma is optional"
- "Users/developers is more inclusive than 'you'"
- "British spelling is fine, readers will understand"

**All of these violate Qt documentation standards. Follow QUIP-25 regardless of time pressure.**

## Common Mistakes and Rationalizations

| Rationalization | Reality | Correction |
|-----------------|---------|------------|
| "will return true sounds clearer" | Future tense weakens documentation | "returns true" (present tense) |
| "passive sounds more formal" | Passive weakens sentences | "the function processes data" (active voice) |
| "i.e./e.g. are standard" | Not accessible to non-native speakers | "that is" / "for example" (no Latin) |
| "Oxford comma is optional" | Qt requires it for consistency | "color, size, and shape" (serial comma) |
| "Users/developers is inclusive" | Qt style uses direct address | "You can call" (use "you") |
| "via is common English now" | Qt style requires native terms | "through the API" or "using the API" |
| "British spelling is acceptable" | Qt uses American English | "color" not "colour", "synchronize" not "synchronise" |

## Style Checklist

Before submitting Qt documentation:

- [ ] American English spelling
- [ ] Active voice throughout
- [ ] Present tense (not future tense)
- [ ] "you" for reader when appropriate
- [ ] No Latin abbreviations (i.e., e.g., etc., via)
- [ ] Serial commas in lists
- [ ] "because" for causation (not "since")
- [ ] QDoc commands properly used (\fn, \a, \c, \l, \sa)
- [ ] Consistent list formatting
- [ ] Clear, concise, unambiguous language

## Reference

- **QUIP-25**: https://contribute.qt-project.org/quips/25
- **Qt Writing Guidelines**: https://wiki.qt.io/Qt_Writing_Guidelines
- **Microsoft Writing Style Guide**: Follow for general technical writing conventions
- **QDoc Manual**: For complete QDoc command reference
