import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.swing.JPanel;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JSpinner;
import javax.swing.JTextField;

import javax.swing.SpinnerListModel;
import javax.swing.SpinnerNumberModel;

import java.time.LocalDate;

import java.awt.Color;
import java.awt.Component;

public class Manager {
    private void setVisibility(boolean isVisible, Component... components) {
        for (Component component : components) {
            component.setVisible(isVisible);
        }
    }

    private void removeAllActionListeners(JButton button) {
        for (var listener : button.getActionListeners()) {
            button.removeActionListener(listener);
        }
    }

    private final Color blue = new Color(1, 50, 67), white = new Color(242, 242, 242);
    private JButton addSpecialization = Create.button("Add specialization", blue, white, 86, 180, null);
    private JButton addClinic = Create.button("Add clinic", blue, white, 136, 360, null);
    private JButton addRoom = Create.button("Add room", blue, white, 134, 540, null);
    private JButton back = Create.button("Back", blue, white, 167, 900, null);

    private final JLabel specialization = Create.label("Specialization", blue, 879, 108);
    private final JLabel clinicID = Create.label("Clinic ID", blue, 905, 108);
    private final JLabel clinicName = Create.label("clinic name", blue, 892, 216);
    private final JLabel clinicFloor = Create.label("Floor", blue, 921, 324);
    private final JLabel clinicSpecialization = Create.label("clinic specialization", blue, 852, 432);
    private final JLabel roomID = Create.label("Room ID", blue, 902, 108);
    private final JLabel roomFloor = Create.label("Room floor", blue, 889, 216);
    private final JLabel roomCapacity = Create.label("Room capacity", blue, 872, 324);

    private JTextField specialization2 = Create.textField(blue, white, blue, 1095, 101, 400, 40);
    private JTextField clinicID2 = Create.textField(blue, white, blue, 1095, 101, 400, 40);
    private JTextField clinicName2 = Create.textField(blue, white, blue, 1095, 209, 400, 40);
    private JTextField clinicFloor2 = Create.textField(blue, white, blue, 1095, 317, 400, 40);
    private JTextField clinicSpecialization2 = Create.textField(blue, white, blue, 1095, 425, 400, 40);
    private JTextField roomID2 = Create.textField(blue, white, blue, 1095, 101, 400, 40);
    private JTextField roomFloor2 = Create.textField(blue, white, blue, 1095, 209, 400, 40);
    private JTextField roomCapacity2 = Create.textField(blue, white, blue, 1095, 317, 400, 40);
    private JTextField message = Create.textField(blue, white, white, 970, 756, 400, 40);

    private JButton confirm = Create.button("Confirm", white, blue, 1107, 864, null);

    public Manager(JPanel sidebar, JButton doctor, JButton nurse, JButton patient, JButton manager, JButton exit, JPanel content, Connection connection) {
        sidebar.add(addSpecialization);
        sidebar.add(addClinic);
        sidebar.add(addRoom);
        sidebar.add(back);

        content.add(specialization);
        content.add(specialization2);
        content.add(clinicID);
        content.add(clinicID2);
        content.add(clinicName);
        content.add(clinicName2);
        content.add(clinicFloor);
        content.add(clinicFloor2);
        content.add(clinicSpecialization);
        content.add(clinicSpecialization2);
        content.add(roomID);
        content.add(roomID2);
        content.add(roomFloor);
        content.add(roomFloor2);
        content.add(roomCapacity);
        content.add(roomCapacity2);
        content.add(message);
        content.add(confirm);

        for (Component component : sidebar.getComponents()) {
            component.setVisible(false);
        }

        for (Component component : content.getComponents()) {
            component.setVisible(false);
        }

        setVisibility(true, addSpecialization, addClinic, addRoom, back);

        addSpecialization.addActionListener(e -> {
            for (Component component : content.getComponents()) {
                component.setVisible(false);
            }

            setVisibility(true, specialization, specialization2, confirm);

            removeAllActionListeners(confirm);

            confirm.addActionListener(e1 -> {
                try {
                    String query = "INSERT INTO Specialization (name, start_date) VALUES (?, ?)";
                    PreparedStatement add = connection.prepareStatement(query);
                    add.setString(1, specialization2.getText());
                    add.setDate(2, Date.valueOf(LocalDate.now()));
                    add.executeUpdate();

                    message.setText("The specialization has been added successfully.");
                    message.setForeground(Color.GREEN);
                    message.setVisible(true);
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            });
        });

        addClinic.addActionListener(e -> {
            for (Component component : content.getComponents()) {
                component.setVisible(false);
            }

            setVisibility(true, clinicID, clinicID2, clinicName, clinicName2, clinicSpecialization, clinicFloor, clinicFloor2, clinicSpecialization2, confirm);

            removeAllActionListeners(confirm);

            confirm.addActionListener(e1 -> {
                try {
                    String query = "SET IDENTITY_INSERT Clinic ON;" + "INSERT INTO Clinic (id, name, floor, specialization) VALUES (?, ?, ?, ?);" + "SET IDENTITY_INSERT Clinic OFF;";
                    PreparedStatement add = connection.prepareStatement(query);
                    add.setInt(1, Integer.parseInt(clinicID2.getText()));
                    add.setString(2, clinicName2.getText());
                    add.setInt(3, Integer.parseInt(clinicFloor2.getText()));
                    add.setString(4, clinicSpecialization2.getText());
                    add.executeUpdate();

                    message.setText("The clinic has been added successfully.");
                    message.setForeground(Color.GREEN);
                    message.setVisible(true);
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            });
        });

        addRoom.addActionListener(e -> {
            for (Component component : content.getComponents()) {
                component.setVisible(false);
            }

            setVisibility(true, roomID, roomID2, roomFloor, roomFloor2, roomCapacity, roomCapacity2, confirm);

            removeAllActionListeners(confirm);

            confirm.addActionListener(e1 -> {
                try {
                    String query = "SET IDENTITY_INSERT Room ON;" + "INSERT INTO Room (id, floor, capacity) VALUES (?, ?, ?);" + "SET IDENTITY_INSERT Room OFF;";
                    PreparedStatement add = connection.prepareStatement(query);
                    add.setInt(1, Integer.parseInt(roomID2.getText()));
                    add.setInt(2, Integer.parseInt(roomFloor2.getText()));
                    add.setInt(3, Integer.parseInt(roomCapacity2.getText()));
                    add.executeUpdate();

                    message.setText("The room has been added successfully.");
                    message.setForeground(Color.GREEN);
                    message.setVisible(true);
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            });
        });

        back.addActionListener(e -> {
            for (Component component : sidebar.getComponents()) {
                component.setVisible(false);
            }

            for (Component component : content.getComponents()) {
                component.setVisible(false);
            }

            setVisibility(true, doctor, nurse, patient, manager, exit);
        });
    }
}