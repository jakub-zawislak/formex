# Upgrade from 0.4 to 0.5

* Ecto has been moved to [formex_ecto](https://github.com/jakub-zawislak/formex_ecto) package

  Just install it and it should work. Except the validation, which is described below.

* the `:required` option **NO LONGER VALIDATES PRESENCE OF VALUE**. It's now used only in template,
  e.g. to generate an asterisk. Validation can be performed via `:validation` option.

  Why? For example, you have form for client, and client can be individual or business.
  A checkbox + JS controls which fields (individual and business related) are currently
  displayed. In previous version of formex you should disable `:required` option of that fields
  (form would always be invalid) and perform validation manually in changeset.
  But then, asterisk at the field will not be displayed, although it's required.

  The above change solves that problem. Now it works in the same way as in Symfony

* you must use an external validator to validate required fields.

  See list of
  [available libraries](https://hexdocs.pm/formex/Formex.Validator.html#available-adapters)

  You have two options to migrate validations:
  1. Use any available validator and:
      - move your validation from `changeset_after_create_callback` to `:validation`
        option of `Formex.Type.add`
      - rewrite translation for error messages, if had any
  2. Use `Formex.Ecto.ChangesetValidator` (from `formex_ecto` package) and:
      - move your validation from `changeset_after_create_callback` to a new callback -
      `changeset_validation` from `Formex.Ecto.ChangesetValidator`.

  The second option is faster.

  And remember, `:required` is no longer used for validation.

* displaying error after submit

  replace

  ```elixir
  <%= if @form.changeset.action do %>oops, error<% end %>
  ```

  with

  ```elixir
  <%= if @form.submitted? do %>oops, error<% end %>
  ```

* `Formex.CustomField.SelectAssoc` renamed to `Formex.Ecto.CustomField.SelectAssoc` and moved to
  `formex_ecto` package