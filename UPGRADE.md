# Upgrade from 0.4 to 0.5

* the `:required` option no longer validates presence of value. It's now used only in template,
  e.g. to generate an asterisk. Validation can be performed via `:validation` option.

  Why? For example, you have form for client, and client can be individual or business.
  A checkbox + JS controls which fields (individual and business related) are currently
  displayed. In previous version of formex you should disable `:required` option of that fields
  (form would always be invalid) and perform validation manually in changeset.
  But then, asterisk at the field will not be displayed, although it's required.

  The above change solves that problem. Now it works in the same way as in Symfony


usunąć translate error z configa

<%= if @form.changeset.action do %>(wyświetl błąd) - już nie ma form.changeset

import Formex.Ecto.Controller

opisać brak walidacji z add_error w changeset callback w type

  use Formex.Ecto.Type