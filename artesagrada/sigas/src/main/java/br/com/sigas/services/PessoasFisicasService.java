package br.com.sigas.services;

import org.slf4j.LoggerFactory;
import org.slf4j.Logger;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.sigas.entities.PessoasFisicas;
import br.com.sigas.repositories.PessoasFisicasRepository;
import jakarta.persistence.EntityExistsException;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;

@Service
public class PessoasFisicasService {

    private static final Logger logger = LoggerFactory.getLogger(PessoasFisicasService.class);

    @Autowired
    private PessoasFisicasRepository pessoasFisicasRepository;

    public PessoasFisicas criarPessoaFisica(PessoasFisicas pessoaFisica) {
        if (pessoasFisicasRepository.buscarPessoaFisicaPorCpf(pessoaFisica.getCpf()).isPresent()) {
            throw new EntityExistsException("CPF já cadastrado");
        }
        return pessoasFisicasRepository.save(pessoaFisica);
    }

    public PessoasFisicas buscarPessoaFisicaPorId(Long id) {
        logger.info("Buscando pessoa física com ID: " + id);
        return pessoasFisicasRepository.buscarPessoaFisicaPorId(id)
                .orElseThrow(() -> new EntityNotFoundException("Pessoa física não encontrada"));
    }

    public PessoasFisicas buscarPessoaFisicaPorCpf(String cpf) {
        return pessoasFisicasRepository.buscarPessoaFisicaPorCpf(cpf)
                .orElseThrow(() -> new EntityNotFoundException("Pessoa física não encontrada"));
    }

    public List<PessoasFisicas> buscarPessoaFisicaPorNome(String nome) {
        return pessoasFisicasRepository.buscarPessoaFisicaPorNome(nome);
    }

    public List<PessoasFisicas> buscarPessoaFisicaPorEmail(String email) {
        return pessoasFisicasRepository.buscarPessoaFisicaPorEmail(email);
    }

    @Transactional
    public void atualizarPessoaFisica(Long id_pessoa, String cpf_pessoa, String nome_pessoa, String email_pessoa, String endereco_pessoa,
            String tel1_pessoa, String tel2_pessoa) {
        pessoasFisicasRepository.atualizarPessoaFisica(id_pessoa, cpf_pessoa, nome_pessoa, email_pessoa, endereco_pessoa, tel1_pessoa, tel2_pessoa);
    }

    @Transactional
    public void deletarPessoaFisicaProcedure(Long id) {
        pessoasFisicasRepository.deletarPessoaFisica(id);
    }
}
