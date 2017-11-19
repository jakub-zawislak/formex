import $ from 'jquery'
import uuidV4 from 'uuid/v4'

export class Collection {

  static run(callback) {
    Collection.listenDOM();

    $(document).on('formex-collection-change', callback)
  }

  static listenDOM() {
    $(document).on('click', '.formex-collection-add', function (e) {
      e.preventDefault()

      Collection.addCollectionItemForm($(this).closest('.formex-collection'))
    })

    $(document).on('click', '.formex-collection-item-remove', function (e) {
      e.preventDefault()

      if (!confirm($(this).data('formex-confirm')))
        return

      let collectionHolder = $(this).closest('.formex-collection')

      let item = $(this).closest('.formex-collection-item')

      collectionHolder.trigger('formex-collection-remove-item', item)

      if (item.is('.formex-collection-item-new')) {
        item.remove()
      } else {
        item.find('[data-formex-remove]').val('true')
        item.hide()
      }

      collectionHolder.trigger('formex-collection-removed-item')
      collectionHolder.trigger('formex-collection-change')
    })
  }

  static addCollectionItemForm(collectionHolder) {
    let prototype   = collectionHolder.data('formex-prototype')
    let indexes     = []
    const items     = collectionHolder.find('.formex-collection-items').first()
    const newIndex  = (items.find('> :last-child').data('formex-index') + 1) || 0

    indexes.push(newIndex)

    collectionHolder.parents('.formex-collection-item').each(function(){
      indexes.push($(this).data('formex-index'))
    })

    indexes = indexes.reverse()

    // console.log(indexes)

    const newItem = Collection.replaceIndexes(prototype, indexes)

    newItem.find('[data-formex-id]').val(uuidV4())
    newItem.data('formex-index', newIndex)

    collectionHolder.find('.formex-collection-items').first().append(newItem)
    collectionHolder.trigger('formex-collection-add-item', items.find('> :last-child'))
    collectionHolder.trigger('formex-collection-change')
  }

  static replaceIndexes(prototype, indexes) {
    let $prototype = $(prototype).find('.formex-collection-item').first()

    function fun(name) {
      let els = $prototype.find('['+name+']')
      $(els).each(function(){
        let newValue = $(this).attr(name)

        for (const k in indexes) {
          const placeholder = new RegExp('__idx'+k+'__', 'g')
          newValue = newValue.replace(placeholder, indexes[k])
        }

        $(this).attr(name, newValue)
      })
    }

    fun('for')
    fun('id')
    fun('name')

    return $prototype
  }

}
