### Steps to Initialize the Game

1. `tanks-phoenix-react$ mix phx.new tanks` create the game
2. `tanks$ sudo su - postgres`
   `postgres$ createuser -d -P tanksdb`
   `tanks$ mix ecto.create`
   create the database
3. `assets$ npm install --save jquery bootstrap@4.0.0 popper.js react react-dom reactstrap@5.0.0-alpha.4 underscore react-konva konva react-redux redux`
4. `assets$ npm install --save-dev babel-preset-env babel-preset-react sass-brunch redux-devtools`
   add dependencies and update the `brunch-config.js`
5. update the `index.html.eex` in `templates/page` and `app.html.eex` in `templates/layout`
