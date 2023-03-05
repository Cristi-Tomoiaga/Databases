import datetime
import random

from faker import Faker
fake = Faker()
fakeRo = Faker('ro-RO')


def generate_clienti(file_name, rows):
    with open(file_name, 'w') as f:
        f.write('USE WebHosting;\n')
        f.write('GO\n\n')
        f.write('DECLARE @id INT;\n\n')

        for _ in range(rows):
            nume = fake.company()[:100]
            cif = fakeRo.unique.vat_id()
            # cif = "RO" + gen_cif if len(gen_cif) < 12 else gen_cif

            line = f'EXEC usp_Create_Client \'{nume}\', \'{cif}\', @id OUTPUT;\n'
            f.write(line)

    fake.unique.clear()


def generate_firme_hosting(file_name, rows):
    with open(file_name, 'w') as f:
        f.write('USE WebHosting;\n')
        f.write('GO\n\n')
        f.write('DECLARE @id INT;\n\n')

        for _ in range(rows):
            nume = fake.company()[:100]
            descriere = fake.catch_phrase()[:200]
            cif = fakeRo.unique.vat_id()
            # cif = "RO" + gen_cif if len(gen_cif) < 12 else gen_cif

            line = f'EXEC usp_Create_FirmaHosting \'{nume}\', \'{descriere}\', \'{cif}\', @id OUTPUT;\n'
            f.write(line)

    fake.unique.clear()


def generate_recenzii(file_name, rows, num_clienti, num_firme):
    with open(file_name, 'w') as f:
        f.write('USE WebHosting;\n')
        f.write('GO\n\n')
        f.write('DECLARE @id INT;\n\n')

        for _ in range(rows):
            id_client = random.randint(1, num_clienti)
            id_firma = random.randint(1, num_firme)
            nota = random.randint(1, 10)
            descriere = fake.paragraph(nb_sentences=1)[:100]
            data_crearii = fake.date_between(datetime.date(2000, 1, 1), datetime.date(2022, 12, 20))

            line = f'EXEC usp_Create_Recenzie {id_client}, {id_firma}, {nota}, \'{descriere}\', \'{data_crearii}\', @id OUTPUT;\n'
            f.write(line)


def generate_all():
    num_clienti = 100000
    num_firme = 100000
    num_recenzii = 100000

    generate_clienti('lab5_gen_clienti.sql', num_clienti)
    generate_firme_hosting('lab5_gen_firmehosting.sql', num_firme)
    generate_recenzii('lab5_gen_recenzii.sql', num_recenzii, num_clienti, num_firme)


if __name__ == '__main__':
    generate_all()
