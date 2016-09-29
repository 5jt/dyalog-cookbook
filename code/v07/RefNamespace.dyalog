:Class RefNamespace
⍝ The only method of this class returns a namespace that is prepared to _
⍝ collect references pointing to GUI controls.
⍝ The namespace is populated with a couple of methods useful to investigate _
⍝ the namespace:
⍝ * The ∆List method returns all or some (depending on the right argument) _
⍝   of the references together with its "Type" & "Caption" (if applicable), _
⍝   and one can restrict the references returned by specifying one or more _
⍝   types as right argument rather than just an empty vector.
⍝ * The ∆GetRefs method return all references in the namespace if the right _
⍝   argument is empty. You can specify one or more "Type"s to restrict the _
⍝   list.
⍝ * ∆GetVersion returns name, version number and version date.
⍝ * ∆GetMethods returns a nested list with the names of all methods.
⍝ Kai Jaeger ⋄ APL Team Ltd

    ∇ n←Create displayName
      :Access Public Shared
    ⍝ Creates an unnamed namespace and populates it with some functions.
    ⍝ The names of those functions start with a "∆" character.
    ⍝ This namespace is designed to collect all the references used _
    ⍝ by/for a particular GUI like a standard form (StdForm).
    ⍝ The right argument is used for ⎕DF if not empty.
      :Access Public Shared
      n←⎕NS⊃'∆Version' '∆List' '∆GetRefs' '∆GetMethods'
      :If ~0∊⍴displayName
          n.⎕DF displayName
      :EndIf
    ∇

    ∇ r←∆Version
      r←(⍕⎕THIS)'1.0.0' '2013-03-30'
    ∇

    ∇ r←∆List type;refs;bool
    ⍝ List all controls with their type and caption (if any)
    ⍝ If "type" is empty, all controls are listed.
    ⍝ if "type" is not empty then only controls are listed of that "type".
    ⍝ "type" can be either a simple string or a vector of strings.
      refs←⎕NL-9
      r←⊃{6 2::'-' '' ⋄ rf←⍎⍵ ⋄ (⊂⍵),(⊂rf.Type),(⊂{0::'' ⋄ ⍵.Caption}rf)}¨refs
      :If ~0∊⍴type
          type←{(,∘⊂∘,⍣(1=≡,⍵))⍵}type
          bool←({0::'' ⋄ ⍵.Type}∘⍎¨refs)∊type
          r←bool⌿r
          r[;0]←⍎¨r[;0]
      :EndIf
    ∇

    ∇ refs←∆GetRefs type
    ⍝ Returns all references in ⎕THIS if the right argument is empty.
    ⍝ if "type" is not empty then only references of that "type" are listed.
    ⍝ "type" can be either a simple string or a vector of strings.
      refs←⍎¨⎕NL-9
      :If ~0∊⍴type
          type←{(,∘⊂∘,⍣(1=≡,⍵))⍵}type
          refs/⍨←refs.Type∊type
      :EndIf
    ∇

    ∇ r←∆GetMethods
    ⍝ Returns a list with all methods.
    ⍝ Those are recognized by naming convention: their names start with a ∆ char.
      r←'∆'⎕NL-3
    ∇

:EndClass