import React from "react"

let url = typeof(window) !== "undefined" ? window.location : "n/a"

export default () => (
  <main style={{ maxWidth: "700px", margin: "4rem auto" }}>
    <h1>Khaled Ezzughayyar</h1>
    <p>This site is under heavy construction. <br/>{url}</p>
  </main>
)
