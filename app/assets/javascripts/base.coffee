$ ->
  Morris.Line
    element: "graph",
    data: $(".results").data("json")
    xkey: "date",
    ykeys: ["result"],
    labels: ["Results/day"]