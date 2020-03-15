import React from "react"

export default () => (
  <main style={{ maxWidth: "700px", margin: "4rem auto" }}>
    <h1>Khaled Ezzughayyar</h1>
    <p>This site is under heavy construction. <br />
      <pre>{typeof (window) === "undefined" ? "" : window.location.href}</pre>
    </p>
  </main>
)
