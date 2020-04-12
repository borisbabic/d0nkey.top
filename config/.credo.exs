%{
  configs: [
    %{
      name: "default",
      checks: [
        {Credo.Check.Design.TagTODO, exit_status: 0}
      ]
    }
  ]
}
