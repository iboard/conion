# Conion


Conion is a package for general Elixir modules 

- A key/value store (`Conion.Store`) that handles `Conion.Store.Bucket`s
  - The `Conion.Store.Persistor` is a `Behaviour` that implements `read!` and `write!`
- Buckets are supervised
- A central `Conion.Common.Configuration` module to deal with compile and runtime
  configuration.
- A central `Conion.Common.CentralLogger` module to do logging in a common manner.


...more to come


## XREF

to create an xref-graph use the following command:

    mix xref graph --format dot  && \
    dot -Tpng xref_graph.dot -o xref_graph.png && \
    open xref_graph.png && \
    sleep 5 && rm xref_graph.*

