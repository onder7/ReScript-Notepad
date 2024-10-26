type note = {
  id: string,
  title: string,
  content: string,
  createdAt: string,
}

// DOM API'leri için binding'ler
module BlobBinding = {
  type t
  @new external makeBlob: (array<string>, {..}) => t = "Blob"
}

module URLBinding = {
  @scope("URL") @val external createObjectURL: BlobBinding.t => string = "createObjectURL"
  @scope("URL") @val external revokeObjectURL: string => unit = "revokeObjectURL"
}

@val external document: {..} = "document"

// Notları txt dosyası olarak dışa aktarma
let exportToTxt = (notes: array<note>) => {
  let content = Belt.Array.reduce(notes, "", (acc, note) => {
    acc ++
    "Başlık: " ++
    note.title ++
    "\nTarih: " ++
    note.createdAt ++
    "\nİçerik: " ++
    note.content ++
    "\n\n-------------------\n\n"
  })

  let blob = BlobBinding.makeBlob([content], {"type": "text/plain;charset=utf-8"})
  let url = URLBinding.createObjectURL(blob)
  
  let a = document["createElement"]("a")
  a["href"] = url
  a["download"] = "notlar.txt"
  document["body"]["appendChild"](a)
  a["click"]()
  document["body"]["removeChild"](a)
  
  URLBinding.revokeObjectURL(url)
}

type state = {
  notes: array<note>,
  currentNote: option<note>,
  newNoteTitle: string,
  newNoteContent: string,
}

type action =
  | AddNote
  | UpdateNoteTitle(string)
  | UpdateNoteContent(string)
  | SelectNote(note)
  | DeleteNote(string)
  | LoadNotes(array<note>)
  | ExportNotes

// LocalStorage işlemleri için yardımcı fonksiyonlar
module Storage = {
  let saveNotes = (notes: array<note>) => {
    let jsonString = Js.Json.stringifyAny(notes)
    switch jsonString {
    | Some(str) => Dom.Storage2.localStorage->Dom.Storage2.setItem("notes", str)
    | None => ()
    }
  }

  let loadNotes = () => {
    switch Dom.Storage2.localStorage->Dom.Storage2.getItem("notes") {
    | Some(str) =>
      switch Js.Json.parseExn(str) {
      | exception _ => []
      | json =>
        switch Js.Json.decodeArray(json) {
        | Some(array) =>
          array
          ->Belt.Array.keepMap(item =>
            switch Js.Json.decodeObject(item) {
            | Some(obj) =>
              switch (
                Js.Dict.get(obj, "id"),
                Js.Dict.get(obj, "title"),
                Js.Dict.get(obj, "content"),
                Js.Dict.get(obj, "createdAt"),
              ) {
              | (Some(id), Some(title), Some(content), Some(createdAt)) =>
                switch (
                  Js.Json.decodeString(id),
                  Js.Json.decodeString(title),
                  Js.Json.decodeString(content),
                  Js.Json.decodeString(createdAt),
                ) {
                | (Some(id), Some(title), Some(content), Some(createdAt)) =>
                  Some({
                    id: id,
                    title: title,
                    content: content,
                    createdAt: createdAt,
                  })
                | _ => None
                }
              | _ => None
              }
            | None => None
            }
          )
        | None => []
        }
      }
    | None => []
    }
  }
}

let initialState = {
  notes: Storage.loadNotes(),
  currentNote: None,
  newNoteTitle: "",
  newNoteContent: "",
}

let reducer = (state, action) => {
  switch action {
  | AddNote =>
    let newNote = {
      id: Js.Date.now()->Js.Float.toString,
      title: state.newNoteTitle,
      content: state.newNoteContent,
      createdAt: Js.Date.make()->Js.Date.toLocaleDateString,
    }
    let newNotes = Belt.Array.concat(state.notes, [newNote])
    Storage.saveNotes(newNotes)
    {
      ...state,
      notes: newNotes,
      newNoteTitle: "",
      newNoteContent: "",
    }
  | UpdateNoteTitle(title) => {...state, newNoteTitle: title}
  | UpdateNoteContent(content) => {...state, newNoteContent: content}
  | SelectNote(note) => {...state, currentNote: Some(note)}
  | DeleteNote(id) =>
    let newNotes = Belt.Array.keep(state.notes, note => note.id != id)
    Storage.saveNotes(newNotes)
    {
      ...state,
      notes: newNotes,
      currentNote: None,
    }
  | LoadNotes(notes) => {...state, notes: notes}
  | ExportNotes =>
    exportToTxt(state.notes)
    state
  }
}

module Styles = {
  let container = "flex min-h-screen bg-gray-100 p-4"
  let sidebar = "w-80 bg-white rounded-lg shadow-md p-4 mr-4"
  let content = "flex-1 bg-white rounded-lg shadow-md p-4"
  let input = "w-full p-2 border rounded-md mb-2"
  let textarea = "w-full p-2 border rounded-md mb-2 h-32 resize-none"
  let button = "w-full bg-blue-500 text-white p-2 rounded-md hover:bg-blue-600 mb-2"
  let exportButton = "w-full bg-green-500 text-white p-2 rounded-md hover:bg-green-600"
  let deleteButton = "bg-red-500 text-white px-2 py-1 rounded-md hover:bg-red-600 text-sm"
  let noteItem = "flex justify-between items-center p-2 border-b hover:bg-gray-50 cursor-pointer"
  let noteList = "mt-4"
  let noteTitle = "text-lg font-semibold"
  let noteContent = "mt-2 text-gray-600"
  let noteDate = "text-sm text-gray-400 mt-2"
  let noNote = "text-gray-500 text-center mt-4"
}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, initialState)

  React.useEffect0(() => {
    let notes = Storage.loadNotes()
    dispatch(LoadNotes(notes))
    None
  })

  <div className={Styles.container}>
    <div className={Styles.sidebar}>
      <input
        type_="text"
        value={state.newNoteTitle}
        onChange={evt => dispatch(UpdateNoteTitle(ReactEvent.Form.target(evt)["value"]))}
        placeholder="Not Başlığı"
        className={Styles.input}
      />
      <textarea
        value={state.newNoteContent}
        onChange={evt => dispatch(UpdateNoteContent(ReactEvent.Form.target(evt)["value"]))}
        placeholder="Not İçeriği"
        className={Styles.textarea}
      />
      <button
        onClick={_ => dispatch(AddNote)}
        disabled={state.newNoteTitle == "" || state.newNoteContent == ""}
        className={Styles.button}>
        {React.string("Not Ekle")}
      </button>
      <button onClick={_ => dispatch(ExportNotes)} className={Styles.exportButton}>
        {React.string("Notları TXT Olarak İndir")}
      </button>

      <div className={Styles.noteList}>
        {React.array(
          Belt.Array.map(state.notes, note =>
            <div key={note.id} className={Styles.noteItem}>
              <div onClick={_ => dispatch(SelectNote(note))}>
                {React.string(note.title)}
              </div>
              <button onClick={_ => dispatch(DeleteNote(note.id))} className={Styles.deleteButton}>
                {React.string("Sil")}
              </button>
            </div>
          ),
        )}
      </div>
    </div>

    <div className={Styles.content}>
      {switch state.currentNote {
      | Some(note) =>
        <div>
          <h2 className={Styles.noteTitle}> {React.string(note.title)} </h2>
          <p className={Styles.noteContent}> {React.string(note.content)} </p>
          <small className={Styles.noteDate}> {React.string(note.createdAt)} </small>
        </div>
      | None => <div className={Styles.noNote}> {React.string("Not seçilmedi")} </div>
      }}
    </div>
  </div>
}