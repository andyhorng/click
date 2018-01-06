defmodule ClickWeb.Router do
  use ClickWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ClickWeb do
    pipe_through :browser # Use the default browser stack

    get "/game/:id", GameController, :welcome
    get "/game/:id/guest/:gid", GameController, :click
    post "/game/:id/guest", GameController, :join

  end

  # Other scopes may use custom stacks.
  # scope "/api", ClickWeb do
  #   pipe_through :api
  # end
end
