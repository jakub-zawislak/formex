# Guides

## Add new items to collection on the backend

You have to generate new collection items with additional `formex_id` values.
The `formex_id` value should be a string and be unique.
JS library adds new items in this way. JS generates `formex_id` using UUID.

If you are using Ecto, then you have to preload that association before adding new items.

Example with Ecto case:

```
user = Repo.get!(User, id)
|> Repo.preload(:addresses)

user = Map.put(user, :addresses, user.addresses ++ [
  %App.Comment{
    country: "default country", # optional
    formex_id: "1" # required. it may be any unique string
  },
  %App.Comment{
    country: "default country of yet another new item",
    formex_id: "2"
  }
])

form = create_form(App.UserType, user)
```

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
