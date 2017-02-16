defmodule Presenter.PageController do
  use Presenter.Web, :controller
  import Ecto.Query#, only: [from: 2]
  use Timex

  def index(conn, _params) do
    IO.puts "+++++"
    IO.inspect filejamaah

    prayerjamaah = File.read!(filejamaah) |> Poison.decode!()
    settings = File.read!(filesettings) |> Poison.decode!()
    messages = File.read!(filemessages) |> Poison.decode!()

    # [fajr, dhuhr, asr, maghrib, isha] = prayerjamaah
    # IO.puts "+++++"
    # IO.inspect prayerjamaah
    # # IO.inspect asr["method"]
    # IO.puts "+++++"

    render conn, "index.html", prayerjamaah: prayerjamaah, settings: settings, messages: messages
  end


  def present(conn, _params) do
    IO.puts "+++++"
    IO.inspect filejamaah

    prayerjamaah = File.read!(filejamaah) |> Poison.decode!()
    settings = File.read!(filesettings) |> Poison.decode!()
    messages = File.read!(filemessages) |> Poison.decode!()

    query_news = from p in "pages",
              left_join: t in "field_title", where: t.pages_id == p.id,
              left_join: b in "field_body", where: b.pages_id == p.id,
              left_join: d in "field_date", where: d.pages_id == p.id,
              left_join: i in "field_images", where: i.pages_id == p.id,
              left_join: o in "field_poster", on: o.pages_id == p.id,
              left_join: h in "field_highlight", where: h.pages_id == p.id
              # where: p.parent_id == 1006#,
              # where: p.parent_id == 1006

              # join: s in "field_ime_suffix", where: s.pages_id == p.id

    query_news = from [p, t, b, d, i, o, h] in query_news,
              select: [p.id, t.data, b.data, d.data, i.data],
              where: p.parent_id == 1022,
              limit: 20,
              order_by: [desc: p.id]

              # order_by: p.id
              # select: p.name
    # query_news = from(q in query_news, distinct: [desc: q.id], order_by: [q.date])



    query_gallery = from p in "pages",
              left_join: t in "field_title", where: t.pages_id == p.id,
              left_join: d in "field_date", where: d.pages_id == p.id,
              left_join: g in "field_gallery", where: g.pages_id == p.id
              # order_by: p.id#not(is_nil(p.published_at))
    query_gallery = from [p, t, d, g] in query_gallery,
              select: [p.id, t.data, d.data, g.data],
              where: p.parent_id == 1022,
              limit: 100,
              order_by: [desc: p.id]




    query_posters = from p in "pages",
              left_join: t in "field_title", where: t.pages_id == p.id,
              left_join: b in "field_body", where: b.pages_id == p.id,
              left_join: d in "field_date", where: d.pages_id == p.id,
              left_join: i in "field_images", where: i.pages_id == p.id,
              left_join: o in "field_poster", where: o.pages_id == p.id
              # order_by: p.id#not(is_nil(p.published_at))
    query_posters = from [p, t, b, d, i] in query_posters,
              select: [p.id, t.data, b.data, d.data, i.data, p.name],
              where: p.parent_id == 1022,
              limit: 5,
              order_by: [desc: p.id]

    highlights = Repo.all(query_news)
    posters = Repo.all(query_posters)
    gallery = Repo.all(query_gallery)

    highlights = Enum.uniq(highlights)
    highlights = Enum.uniq_by(highlights, fn [id, title, body, date, images] -> id end)
    highlights = Enum.slice(highlights, 0..4)

    IO.puts "+++highlights+++"
    IO.inspect highlights
    IO.puts "+++posters+++"
    IO.inspect posters    
    IO.puts "+++gallery+++"
    IO.inspect gallery


    render conn, "present.html", prayerjamaah: prayerjamaah, settings: settings, messages: messages, highlights: highlights, posters: posters, gallery: gallery
  end



  defp filejamaah() do
    Path.join(:code.priv_dir(:presenter), "static/js/db/jamaah.json")
  end

  defp filesettings() do
    Path.join(:code.priv_dir(:presenter), "static/js/db/settings.json")
  end

  defp filemessages() do
    Path.join(:code.priv_dir(:presenter), "static/js/db/messages.json")
  end

end

