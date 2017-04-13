// This module is unfinished. It doesn't support collections of collections.
// Another issue is jQuery dependency :D

import $ from 'jquery'

export class Collection {

  static run(callback) {
    Collection.resetIndexes()
    Collection.replacePrototypeNames()
    Collection.listenDOM();

    $(document).on('formex-collection-change', callback)
  }

  // to poprawić jeśli będzie wiele poziomów
  static resetIndexes() {
    $('.formex-collection').each(function () {
      $(this).data('formex-index', $(this).find('.formex-collection-item').length)
    })
  }

  static replacePrototypeNames() {
    $('[data-formex-prototype]').each(function () {
      let data = $(this).data('formex-prototype')

      // idzie od końca
      data = data.replace(/([0-9a-z\[\]_]+)_0_([0-9a-z\[\]_]+)/gi, '$1___name___$2')
      // data = data.replace(/([0-9a-z\[\]_]+)_0_([0-9a-z\[\]_]+)/gi, '$1___name2___$2')
      data = data.replace(/([0-9a-z\[\]_]+)\[0\]([0-9a-z\[\]_]+)/gi, '$1[__name__]$2')
      // data = data.replace(/([0-9a-z\[\]_]+)\[0\]([0-9a-z\[\]_]+)/gi, '$1[__name2__]$2')

      $(this).data('formex-prototype', data)
    })

    /*
    * nieskończona funkcja która powinna w id z __name__ zamieniać wszystkie name2 na name w przypadku gdy nie ma name
    * to samo z name22 na name2 itd (to niezrobione)
    * może tak być wtedy gdy wyślemy formularz - id już jest ustawione za name, a name2 powinno być name lecz nie jest
    */
    // $('[data-formex-prototype]').each(function () {
    //   let data = $(this).data('formex-prototype')
    //
    //   data = data.replace(/("[0-9a-z\[\]_]+((?!.*__name__).)[0-9a-z\[\]_]+)__name2__([0-9a-z\[\]_]+")/gi, '$1__name__$3')
    //
    //   $(this).data('formex-prototype', data)
    // })
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

      if (!item.is('.formex-collection-item-new')) {
        item.find('.formex-collection-item-remove-checkbox').val('true')
        item.hide()
      } else {
        item.remove()
      }

      collectionHolder.trigger('formex-collection-removed-item')
      collectionHolder.trigger('formex-collection-change')
    })
  }


  static addCollectionItemForm(collectionHolder) {
    let prototype = collectionHolder.data('formex-prototype')
    let index = collectionHolder.data('formex-index')

    prototype = Collection.replaceIndex(prototype, /__name__/g, index)

    // if (collectionHolder.closest('.formex-collection-item').length) {
    //   let parentItem = collectionHolder.closest('.formex-collection-item')
    //   let parentItemCollection = parentItem.closest('.formex-collection')
    //   let parentItemCollectionItems = parentItemCollection.find('> .formex-collection-item')
    //   let parentIndex
    //
    //   for (let k in parentItemCollectionItems) {
    //     if (parentItemCollectionItems[k] == parentItem[0]) {
    //       parentIndex = k
    //       break
    //     }
    //   }
    //
    //   prototype = Collection.replaceIndex(prototype, /__name2__/g, parentIndex)
    // }

    collectionHolder.find('.formex-collection-items').append(prototype)
    collectionHolder.trigger('formex-collection-add-item', collectionHolder.find('> :last-child'))
    collectionHolder.trigger('formex-collection-change')

    Collection.resetIndexes()
  }

  static replaceIndex(prototype, placeholder, index) {
    let $prototype = $(prototype).find('.formex-collection-item').first()

    function fun(name) {
      let els = $prototype.find('['+name+']')
      $(els).each(function(){
        $(this).attr(name, $(this).attr(name).replace(placeholder, index))
      })
    }

    fun('for')
    fun('id')
    fun('name')
    fun('href')

    return $prototype
  }

}
