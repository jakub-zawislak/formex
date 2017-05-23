## v0.4.16 (2017-05-23)
* Template now converts `\n` to `<br>` in error messages using `Phoenix.HTML.Format.text_to_html\2`

## v0.4.15 (2017-04-27)
* Added `form` parameter in `Formex.Type.changeset_after_create_callback`

## v0.4.14 (2017-04-27)
* Fixed passing `form.opts` to a prototype form in `Formex.View.Collection`

## v0.4.13 (2017-04-18)
* Temporarily removed ability to filter collection items, that was added in the 0.4.10

## v0.4.11 (2017-04-17)
* Added `Formex.View.formex_input` and `Formex.View.formex_label`

## v0.4.10 (2017-04-16)
* Ability to filter items in form collections
* Improved code of form collections. It's required to update JS library:
  Run `npm install formex`.

## v0.4.8 (2017-04-13)
* Added prefixes `formex-` in HTML attributes (`data-prototype` is now `data-formex-prototype` etc.).
  Run `npm install formex` to update JS library.

## v0.4.7 (2017-04-12)
* Fixed "`Phoenix.HTML.Form.Formex.CustomField.SelectAssoc/3` is undefined" errors
* Added `opts` argument in `Formex.Builder/4`

## v0.4.6 (2017-04-10)
* Fixed collections where items has ID as UUID instead of integer. `embedded_schema`
  uses UUID.

## v0.4.5 (2017-04-09)
* Fixed JS library

## v0.4.4 (2017-04-01)
* Added
  * Ability to use with `embedded_schema`, without a database

## v0.4.1 (2017-03-24)
* Added
  * Collections of forms
  * Ability to write templates of nested forms
* Changed
  * API of `Formex.View`

    Use `use Formex.View` instead of `import Formex.View` inside your web.ex

## v0.4.0 (2017-03-08)
* Changed API of `Formex.Type`
  * swapped second and third argument of `Formex.Type.add\4`.

    Instead of:
    ```elixir
    |> add(:text_input, :title)
    ```
    write:
    ```elixir
    |> add(:title, :text_input)
    ```
    The order of arguments is now the same as in Symfony.
  * removed `Formex.Type.add_button\4`. Use `Formex.Type.add\4` instead.
  * removed `Formex.Type.add_form\4`. Use `Formex.Type.add\4` instead.

## v0.3.3 (2017-03-06)
* Added
  * Nested forms with `_to_one` relation

## v0.3.2 (2017-02-22)
* Added
  * SelectAssoc
    * multiple_select support
  * Select
    * Validation if value sent by user exists in the generated select

## v0.3.1 (2017-02-18)
* Added
  * `Formex.Template.add_class`

## v0.3.0 (2017-02-17)
* Added
  * Ability to create a custom templates
  * Templates
    * Bootstrap horizontal
    * Bootstrap vertical
* Changed
  * Extracted repo functions from a `Formex.Builder` to a `Formex.Repo`.
  * `web/web.ex` - You have to `use Formex.Controller` instead of
    `import Formex.Builder` from now on.

* Removed
  * `formex_row_horizontal` and `formex_rows_horizontal`.
    You have to use a horizontal template from now on.

## v0.2.3 (2017-02-12)

* Added
  * Select Assoc
    * `group_by` option

## v0.2.2 (2017-02-09)

* Added
  * Select Assoc
    * `query` option
* Changed
  * Select Assoc
    * renamed `choice_name` to `choice_label`

## v0.2.1 (2017-02-07)

* Added
  * tests

## v0.2.0 (2017-01-28)

* Added
  * custom fields
