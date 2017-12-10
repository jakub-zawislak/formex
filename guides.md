# Guides

## Using a select picker plugin with ajax search

If you are using a JS plugin for `<select>`
(e.g. [Ajax-Bootstrap-Select](https://github.com/truckingsim/Ajax-Bootstrap-Select))
and you want to enable ajax search, you have to do these steps:.

  1. Add a `without_choices: true` option. From now only already selected `<option>`'s will
    be rendered in the `<select>` field.

    ```elixir
    form
    |> add(:customer, :select,
      without_choices: true
    )
    ```

  2. Add a `:choice_label_provider` function. This function receives a value from selected
    `<option>` and returns proper label.

    Note: If you are using `SelectAssoc` from
    [`Formex.Ecto`](https://github.com/jakub-zawislak/formex_ecto),
    then this function is automatically implemented.

    ```elixir
    form
    |> add(:customer, :select,
      without_choices: true,
      choice_label_provider: fn id ->
        # get a label for this id from database or another source
        Repo.get(Customer, id).name
      end
    )
    ```

  3. Put code that is required by your JS plugin. Example for Ajax Bootstrap Select:

    ```elixir
    form
    |> add(:customer, :select,
      without_choices: true,
      choice_label_provider: fn id ->
        # get a label for this id from database or another source
        Repo.get(Customer, id).name
      end,
      phoenix_opts: [
        class: "select",
        data: [
          live_search: true,
          abs_ajax_url: "YOUR URL",
          # ... other ajax bootstrap select options
        ]
      ]
    )
    ```

      ```javascript
      $('.select').selectpicker().ajaxSelectPicker()
      ```

  4. (Optional) If you are using the `SelectAssoc`, use
    [SelectAssoc.search/3](https://hexdocs.pm/formex_ecto/Formex.Ecto.CustomField.SelectAssoc.html#search/3)
    function inside your controller.
